#!/bin/bash

# 스크립트 실행 중 오류 발생시 종료
set -e

echo "=== LVM 설정 스크립트 시작 ==="

sudo yum install lvm2

# 1. 새 디스크 확인
echo "현재 디스크 목록 : "
lsblk

read -p "LVM으로 설정할 새 디스크를 입력하세요 (예 : /dev/sdb) : " new_disk

# 디스크 존재 확인
if [ ! -b "$new_disk" ]; then 
    echo "오류 : $new_disk 디스크를 찾을 수 없습니다."
    exit 1
fi

# 2. 디스크 초기화
echo "$new_disk 디스크를 초기화 합니다."
sudo pvcreate "$new_disk"

# 3. Volume Group 생성
read -p "생성 할 Volume Group 이름을 입력하세요 (기본 : vg_data) : " vg_name
vg_name = $(vg_name:-vg_data)

echo "Volume Group $vg_name 를 생성합니다. "
sudo vgcreate "$vg_name" "$new_disk"

# 4. Logical Volume 생성
read -p "생성 할 Logical Volume 이름을 입력하세요 (기본 : lv_data) : " lv_name
lv_name = $(lv_name:-lv_data)

read -p "Logical Volume 크기를 입력하세요 (예 : 10G 전체 : 100%FREE) : " lv_size
lv_size = $(lv_size:-100%FREE)

echo "Logical Volume $lv_name 를 $lv_size 크기로 생성합니다."
sudo lvcreate -L "$lv_size" -n "$lv_name" "$vg_name"

# 5. 파일시스템 생성
read -p "마운트 할 디렉토리를 입력하세요 (예: /mnt/data) : " mount_point

if [ ! -d "$mount_point" ]; then
    echo "마운트 디렉토리 $mount_point 를 생성합니다."
    sudo mkdir -p "$mount_point"
fi

echo "Logical Volume 을 $mount_point 에 마운트 합니다."
sudo mount "/dev/$vg_name" "$mount_point"

# 7. fstab에 추가
echo "마운트를 유지하기 위해 /etc/fstab 에 추가합니다."
uuid = $(blkid -s UUID -o value "/dev/$vgname/$lv_name")
echo "UUID=$UUID $mount_point $fs_type defaults 0 0" | sudo tee -a /etc/fstab

# 8. 결과 확인
echo "=== 설정 완료 ==="
lsblk 
df -Th | grep "$mount_point"

echo "LVM 설정 및 마운트 완료!"
