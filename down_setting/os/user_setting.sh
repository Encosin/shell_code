#!/bin/bash

# 스크립트 실행 중 오류 발생시 종료
set -e

# 추가핧 유저 이름을 설정합니다.

# 1. 사용자 이름 입력받기
read -p "추가 할 사용자 이름을 입력하세요 : " username

# 입력이 비어있을 경우 종료
if [ -z "$username" ]; then 
    echo "사용자 이름을 입력하지 않았습니다. 스크립트 실행을 종료합니다."
    exit 1
fi 

# 2. 사용자가 이미 존재하는지 확인
if id "$username" &>/dev/null; then 
    echo "사용자 '$username' 은 이미 존재합니다."
    exit 1
fi

# 3. 사용자 추가
echo "사용자 '$username'을 추가합니다."
sudo useradd -m -s /bin/bash "$username"

# 4. 암호 설정
echo "사용자 '$username' 의 암호를 설정합니다."
sudo passwd "$username"

# 5. sudo 그룹에 추가 여부 확인
read -p "사용자 '$username'을 sudo 그룹에 추가하시겠습니까? (y/n) " add_sudo

if [[ "$add_sudo" == "y" || "$add_sudo" == "Y" ]]; then 
    sudo usermod -aG wheel "$username"
    echo "사용자 '$username' 이 sudo 그룹에 추가되었습니다. "
else
    echo "sudo 그룹 추가를 건너뜁니다."
fi

# 6. 사용자 추가 확인
echo "=== 사용자 추가 작업 완료 ==="
id "$username"