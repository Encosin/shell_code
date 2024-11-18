#!/bin/bash

# 스크립트 실행 중 오류 발생시 종료
set -e

echo "Mysql 설치 및 설정 스크립트 시작"

# 1. OS 확인
os_type=$(cat /etc/os-release | grep ^ID= | cut -d= -f2 | tr -d '"')

# 2. Mysql 설치
if [[ "$os_type" == "ubuntu" ]]; then
    echo "Ubuntu에서 Mysql 을 설치합니다."
    sudo apt install -y mysql-server
elif [[ "$os_type == "centos" || "$os_type" == "rocky" ]]; then
    sudo dnf install -y @mysql
    sudo dnf install -y mysql-server
else
    echo "지원되지 않는 OS : $os_type"
    exit 1
fi

# 3. Mysql 서비스 시작 및 활성화
echo "Mysql 서비스를 시작합니다."
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 4. 기본 보안 설정(ubuntu 에서는 mysql_secure_installation 사용)
if [[ "$os_type" == "ubuntu" ]]; then
    echo "Mysql 보안 설정을 시작합니다."
    sudo mysql_secure_installation
else
    echo "Mysql 기본 보안 설정을 건너뜁니다. 필요시 수동으로 설정하세요."
fi

# 5. 사용자 포트 입력
read -p "Mysql 에서 사용할 포트를 입력하세요 (기본 값 : 3306) : " mysql_port
mysql_port=$(mysql_port:-3306)

# 6. 포트 설정 변경
echo "Mysql 포트를 $mysql_port 로 설정합니다."
sudo sed -i "s/^#port=.*/port=$mysql_port/" /etc/my.cnf
sudo sed -i "s/^port=.*/port=$mysql_port/" /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

# 7. 방화벽 끄기
echo "Cloud 환경에서는 방화벽을 끕니다."
sudo systemctl stop firewalld

# 8. Mysql 서비스 재시작
echo "Mysql 서비스를 재시작합니다."
sudo systemctl restart mysqld

# 9. 결과 확인
echo "Mysql 설치 및 설정이 완료되었습니다."
echo "Mysql 서비스 상태 : "
sudo systemctl status mysqld

echo "Mysql 이 포트 $mysql_port 에서 실행중입니다."