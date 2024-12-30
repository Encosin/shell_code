#!/bin/bash

# 1. Java 버전 입력받기
echo "설치할 Java 버전을 입력하세요 (예: java-1.8.0-openjdk) : "
read java_version

# 2. Tomcat 버전 입력받기
echo "설치할 Tomcat 버전을 입력하세요 (예 : 9.0.62) : "
read tomcat_version

# 3. 패키지 업데이트 및 필수 의존성 설치
echo "필수 패키지를 설치합니다."
sudo dnf update -y
sudo dnf install -y $java_version wget

# 4. Java 설치
echo "Java $java_version 버전을 설치 중입니다..."
sudo dnf install -y $java_version

# 5. Java 환경 변수 설정
echo "JAVA_HOME을 설정 중입니다..."
sudo bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/$java_version' >> /etc/profile.d/java.sh"
sudo bash -c "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/profile.d/java.sh"
source /etc/profile.d/java.sh


# 8. Tomcat 설치
cd ..
echo "Tomcat $tomcat_version 버전을 다운로드 중입니다.."
wget https://archive.apache.org/dist/tomcat/tomcat-9/v$tomcat_version/bin/apache-tomcat/bin/apache-tomcat-$tomcat_version.tar.gz

echo "Tomcat 소스 파일을 추출 중입니다.."
tar -xvzf apache-tomcat-$tomcat_version.tar.gz
cd apache-tomcat-$tomcat_version

# 7. Tomcat AJP 커넥터 설정
echo "Tomcat의 AJP 커넥터 포트를 설정 중입니다.."
# server.xml 에서 AJP 포트 활성화
sudo sed -i 's/<!--<Connector port="8009" protocol="AJP\/1.3" redirectport="8443" \/>/ <Connector port="8009" protocol="AJP\/1.3" redirectPort="8443" \/>/' conf/server.xml


# 8. Tomcat을 백그라운드에서 실행하기 위한 systemd 서비스 파일 설정
echo "Tomcat을 백그라운드에서 실행하기 위한 systemd 서비스 파일을 설정 중입니다..."

cat <<EOL | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
PIDFile=/opt/tomcat/apache-tomcat-$tomcat_version/temp/tomcat.pid
ExecStart=/opt/tomcat/apache-tomcat-$tomcat_version/bin/startup.sh
ExecStop=/opt/tomcat/apache-tomcat-$tomcat_version/bin/shutdown.sh
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/$java_version"
Environment="CATALINA_PID=/opt/tomcat/apache-tomcat-$tomcat_version/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat/apache-tomcat-$tomcat_version"
Environment="CATALINA_BASE/opt/tomcat/apache-tomcat-$tomcat_version"

[Inatall]
WantedBy=multi-user.target
EOL

# 9. Tomcat 서비스 시작 및 자동 시작 설정
echo "Tomcat 서비스를 시작하고 자동 시작되도록 설정 중입니다..."
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

# 10. 설치 확인
echo "Tomcat 설치가 완료되었습니다. 웹 브라우저에서 http://localhost:8080 으로 접속해보세요."

