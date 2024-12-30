#!/bin/bash

set -e

echo "== Docker 설치 및 설정 스크립트 =="

# 1. OS 확인
os_type=$(cat /etc/os-release | grep ^ID= | cut -d= -f2 | tr -d '"')

# 2. Docker 설치
if [[ "$os_type" == "ubuntu" ]]; then
    echo "Ubuntu에서 Docker 를 설치합니다."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg  --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive--keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt -update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
elif [[ "$os_type" == "centos" || "$os_type" == "rocky" ]]; then
    echo "Centos/Rocky에서 Docker를 설치합니다."
    sudo dnf -y install yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-ce docker-cli containerd.io
else
    echo "지원되지 않는 OS : $os_type"
    exit 1
fi

# 3. Docker 서비스 시작 및 활성화
echo "Docker 서비스를 시작하고 활성화합니다..."
sudo systemctl start docker
sudo systemctl enable docker

# 4. Docker 설치 확인
docker_version=$(docker --version)
echo "Docker 설치 완료 : $docker_version"

# 5. 사용자 권한 추가
read -p "현재 사용자 (${USER})를 Docker 그룹에 추가하시겠습니까? (y/n) : " add_user
if [[ "$add_user" == "y" ]]; then
    sudo usermod -aG docker "$USER"
    echo "Docker 그룹에 사용자가 추가되었습니다. 변경 사항 적용을 위해 로그아웃 후 다시 로그인하세요."
fi

# 6. 테스트 : hello-world 실행
read -p "Docker 설치 확인을 위해 'hello-world' 컨테이너를 실행하시겠습니까? (y/n) : " run_test
if [[ "$run_test" == "y" ]]; then
    sudo docker run hello-world
fi

echo "=== Docker 설치 및 설정이 완료되었습니다! ==="
