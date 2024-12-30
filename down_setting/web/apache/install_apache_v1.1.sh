#!/bin/bash

# 사용자로부터 Apache 버전을 입력받고, 그에 맞는 소스를 다운로드하여 설치합니다.

# 1. 패키지 업데이트 및 필수 의존성 설치
echo "필수 패키지를 설치합니다."
sudo dnf update -y
sudo dnf install -y gcc pcre-devel make automake wget apt-devel apr-util-devel

# 2. Apache 버전 입력 받기
echo "설치할 Apache 버전을 입력하세요. (예: 2.4.62): "
read apache_version

# 3. Apache 소스 다운로드
echo "Apache $apache_version 버전을 다운로드 중입니다."
wget https://downloads.apache.org/httpd/httpd-$apache_version.tar.gz

# 4. 다운로드한 파일을 추출
echo "소스 파일을 추출중입니다..."
tar -xvf httpd-$apache_version.tar.gz

# 5. 디렉토리 이동
cd httpd-$apache_version

# 6. Apache 빌드 및 설치
echo "Apache를 빌드하고 설치중입니다."
./configure --enable-so --enable-ssl --with-mpm-prefork
make
sudo make install

# 7. Apache 서비스 시작 및 자동 시작 설정
echo "Apache 서비스 시작 중..."
sudo systemctl start httpd
sudo systemctl enable httpd

# 8. 설치 확인
echo "Apache 설치가 완료되었습니다. 버전을 확인해보세요:"
/usr/local/apache/bin/httpd -v

