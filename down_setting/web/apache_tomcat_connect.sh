#!/bin/bash

# Apache 및 Tomcat 설치 스크립트
# 사용자로부터 Apache와 Tomcat 버전을 입력받고, 두 SW를 설치 후 연동합니다.

# 1. 패키지 업데이트 및 필수 의존성 설치
echo "필수 패키지를 설치합니다."
sudo dnf update -y
sudo dnf install -y gcc pcre-devel make automake wget apr-devel apr-util-devel 

# 2. Java 버전 입력받기
echo "설치할 Java 버전을 입력하세요 (예: java-1.8.0-openjdk) : "
read java_version

# 3. Apache 버전 입력받기
echo "설치할 Apache 버전을 입력하세요 (예 : 2.4.62) : "
read apache_version

# 4. Tomcat 버전 입력받기
echo "설치할 Tomcat 버전을 입력하세요 (예 : 9.0.62) : "
read tomcat_version

# 5. Java 설치
echo "Java $java_version 버전을 설치 중입니다..."
sudo dnf install -y $java_version

# 6. Java 환경 변수 설정
echo "JAVA_HOME을 설정 중입니다..."
sudo bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/$java_version' >> /etc/profile.d/java.sh"
sudo bash -c "echo 'export PATH=\$JAVA_HOME/bin:/\$PATH' >> /etc/profile.d/java.sh"
source /etc/profile.d/java.sh

# 7. Apache 소스 다운로드 및 설치
echo "Apache $apache_version 버전을 다운로드 중입니다..."
wget https://downloads.apache.org/httpd/httpd-$apache_version.tar.gz

echo "소스 파일을 추출중입니다."
tar -xvzf httpd-$apache_version.tar.gz
cd httpd-$apache_version

echo "Apache를 빌드하고 설치 중입니다..."
./configure --enable-so --enable-ssl --with-mpm=prefork
make
sudo make install

# 8. Tomcat 설치
cd ..
echo "Tomcat $tomcat_version 버전을 다운로드 중입니다.."
wget https://archive.apache.org/dist/tomcat/tomcat-9/v$tomcat_version/bin/apache-tomcat