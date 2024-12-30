#!/bin/bash

# 스크립트 실행 중 오류 발생 시 종료
set -e

echo "=== Nginx 설치 스크립트 시작 ==="

# 1. Nginx 설치
echo "[1/3] Nginx 설치 중..."
sudo yum install -y epel-release
sudo yum install -y nginx

# 2. Nginx 서비스 활성화 및 시작
echo "[2/3] Nginx 서비스 시작 및 부팅 시 자동 시작 설정 중..."
sudo systemctl enable nginx
sudo systemctl start nginx

# 3. 방화벽 설정(HTTP/HTTPS 허용)
sudo firewall-cmd --permananet --add-service=http
sudo firewall-cmd --permananet --add-service=https
sudo firewall-cmd --reload

# Nginx 상태 확인
echo "=== Nginx 설치 및 설정 완료 ==="
sudo systemctl status nginx --no-pager

echo "웹 서버가 성공적으로 설치되고 실행 중입니다!"
echo "기본 웹페이지를 확인하려면 브라우저에서 http://<서버_주소>를 열어보세요."