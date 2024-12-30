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

# 7. SSH 포트 변경
read -p "변경할 SSH 포트를 입력하세요 (기본: 22) : " ssh_port
ssh_port = $(ssh_port:-22) # 기본 값은 22

echo "SSH 포트를 $ssh_port로 변경합니다."
sudo sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
sudo sed -i "s/^Port [0-9]*/Port $ssh_port/" /etc/ssh/sshd_config

# 8. Root 로그인 비활성화
echo "Root 사용자의 SSH 로그인을 비활성화합니다."
sudo sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

# 9. 비밀번호 만료 추가 설정(90일)
echo "비밀번호 만료 주기를 90일로 설정합니다..."
sudo chage -M 90 "$username"

# 설정 확인 완료
echo "설정된 비밀번호 만료 정보 : "
sudo chage -l "$username"

# 10. SSH 서비스 재시작
echo "SSH 서비스를 재시작합니다..."
sudo systemctl restart sshd

# 11. 방화벽 비활성화
read -p "방화벽을 비활성화하시겠습니까? (y/n) : " disable_firewall
if [[ "$disable_firewall" == "y" || "$disable_firewall" =="Y" ]]; then
    echo "방화벽을 비활성화 합니다."
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
    echo "방화벽이 비활성화 되었습니다."
else
    echo "방화벽 설정은 변경하지 않습니다."
fi

# 12. 설정 확인
echo "===초기 설정 완료 ==="
echo "SSH 포트 : $ssh_port"
echo "Root 로그인 비활성화 상태 : 확인 완료"
echo "방화벽 상태 : "
sudo systemctl status firewalld --no-pager

echo "설정이 완료되었습니다. SSH로 접속 시 포트 $ssh_port 를 사용하세요."
