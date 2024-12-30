#!/bin/bash

# 사용자로부터 Apache 버전을 입력받고, 그에 맞는 소스를 다운로드하여 설치합니다.

# 1. Apache 버전 입력 받기
echo "설치할 Apache 버전을 입력하세요. (예: 2.4.62): "
read apache_version

# 2. Tomcat WAS 서버의 IP 주소 입력받기
echo "Tomcat WAS 서버의 IP 주소를 입력하세요 : "
read tomcat_ip

# 3. 패키지 업데이트 및 필수 의존성 설치
echo "필수 패키지를 설치 중입니다."
sudo dnf update -y
sudo dnf install -y gcc pcre-devel make automake wget apr-devel apr-util-devel

# 4. Apache 소스 다운로드
echo "Apache $apache_version 버전을 다운로드 중입니다."
wget https://downloads.apache.org/httpd/httpd-$apache_version.tar.gz

echo "소스 파일을 추출중입니다..."
tar -xvzf httpd-$apache_version.tar.gz
cd httpd-$apache_version

echo "Apache를 빌드하고 설치중입니다."
./configure --enable-so --enable-ssl --with-mpm-prefork
make
sudo make install

# 5. Apache와 Tomcat 연동 설정
echo "Apache와 Tomcat 연동을 위한 설정을 추가 중입니다..."

# Apache의 httpd.conf 파일에 mod_proxy와 mod_proxy_ajp 설정 추가
sudo bash -c "echo 'Load Module proxy_module modules/mod_proxy.so' >> /usr/local/apache/conf/httpd.conf"
sudo bash -c "echo 'Load Module proxy_ajp_module modules/mod_proxy_ajp.so' >> /usr/local/apache/conf/httpd.conf"
sudo bash -c "echo 'ProxyPass /tomcat/ ajp://$tomcat_ip:8009/' >> /usr/local/apache/conf/httpd.conf"
sudo bash -c "echo ProxyPassReverse /tomcat/ ajp://$tomcat_ip:8009/' >> /usr/local/apache2/conf/httpd.conf"

# 6. Apache 서비스 시작 및 자동 시작 설정
echo "Apache 서비스 시작 중..."
sudo systemctl start httpd
sudo systemctl enable httpd

# 7. 설치 확인
echo "Apache 설치가 완료되었습니다. 버전을 확인해보세요:"
/usr/local/apache/bin/httpd -v

