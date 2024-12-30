#!/bin/bash

# 스크립트 실행 중 오류 발생시 종료
set -e

echo "=== fdisk 및 LVM 설정 스크립트 시작 ==="

# 1. 새 디스크 확인
echo "현재 디스크 출력"
lsblk

read -p "LVM으로 설정할 새 디스크를 입력하세요 (예 : /dev/sdb) :" new_disk

# 디스크 존재 확인
if [ ! -b "#new_disk" ]; then
    echo "오류 : $new_disk 디스크를 찾을 수 없습니다."
    exit 1
fi

# 2. fdisk 로 파티션 생성
echo "$new_disk에서 새로운 파티션을 생성합니다..."
sudo fdisk "$new_disk" << EOF
n
p
1

t
8e
w
EOF

echo "fdisk로 파티션 생성이 완료되었습니다."

# 3. 디스크 파티션 경로 확인
new_partition="$(new_disk)1"

if [ ! -b "$new_partition" ]; then
    echo "오류 : 파티션 $new_partition 이 생성되지 않았습니다."
    exit 1
fi

echo "새 파티션 : $new_partition"

# 4. 파티션을 LVM 으로 설정
echo "새 파티션을 LVM으로 초기화 합니다."
sudo pvcreate "$new_partition"

# 5. Volume Group 생성
read -p "생성할 Volume Group 이름을 입력하세요 (기본 : vg_data) : " vg_name
vg_name=$(vg_name:-vg_data)

echo "Volume Group $vg_name 를 생성합니다."
sudo vgcreate "$vg_name" "$new_partition"

# 6. Logical Volume 생성
read -p "생성할 Logical Volume 이름을 입력하세요 (기본 : lv_data) : " lv_name
lv_name=$(lv_name:-lv_data)

read -p "Logical Volume 크기를 입력하세요 (예: 10G, 전체 100%FREE): " lv_size
lv_size=$(lv_size:-100%FREE)

echo "Logical Volume $lv_name 를 $lv_size 크기로 생성합니다"
sudo lvcreate -L "$lv_size" -n "$lv_name" "$vg_name"

# 7. 파일 시스템 생성
read -p "사용할 파일 시스템을 입력하세요 (ext4, xfs, etc) [기본 xfs] : " fs_type
fs_type=${fs_type:-xfs}

echo "$fs_type 파일 시스템을 생성합니다."
sudo mkfs."$fs_type" "/dev/$vg_name/$lv_nmae"

# 8. 마운트 디렉토리 설정
read -p "마운트할 디렉토리를 입력하세요 (예: /mnt/data) : " mount_point

if [ ! -d "$mount_point" ]; then
    echo "마운트 디렉토리 $mount_point 를 생성합니다."
    sudo mkdir -p "$mount_point"
fi

echo "Logical Volume 을 $mount_point 에 마운트 합니다."
sudo mount "/dev/$vg_name/$lv_name" "$mount_point"

# 9. fstab에 추가
echo "마운트를 유지하기 위해 /etc/fstab 에 추가합니다."
uuid=$(blkid -s UUID -o value "/dev/$vg_name/$lv_name")
echo "UUID=$uuid $mount_point $fs_type defaults 0 0" | sudo tee -a /etc/fstab

# 10. 결과 확인
echo "설정 완료"
lsblk
df -Th | grep "$mount_point"

echo "fdisk 및 LVM 설정이 완료됐습니다."

