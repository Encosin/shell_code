#!/bin/bash

# 스크립트 실행 중 오류 발생시 종료.
set -e

echo "=== Apache 설치 시작 ==="

# 1. Apache 설치
echo "[1/3] Apache 설치"
yum install -y httpd

# 2. Apache 서비스 활성화 및 시작
echo "[2/3] Apache 서비스 시작 및 부팅 시 자동 시작 설정 중"
sudo systemctl enable httpd
sudo systemctl start httpd

# 3. 방화벽 설정 (HTTP/HTTPS 허용)
echo "[3/3] 방화벽에서 HTTP/HTTPS 트래픽 허용 설정 중"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Apache 상태 확인
echo "=== Apache 설치 및 설정 완료==="
sudo systemctl status httpd --no-pager

echo "웹 서버가 성공적으로 설치되고 실행 중입니다!"
echo "기본 웹페이지를 확인하려면 브라우저에서 http://<서버주소>를 열어보세요."
