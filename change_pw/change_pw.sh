#!/bin/bash

# /etc/passwd 에서 UID가 1000 이상인 사용자 목록을 가져옵니다. 
users=$(awk -F: '($3 >= 1000 || $1 == "root") {print $1}' /etc/passwd)

# 각 사용자의 비밀번호 변경 날짜를 출력합니다. 
echo "현재 비밀번호 변경 날짜 (root 및 UID가 1000 이상인 사용자): "
for user in $users; do
	if [ -d "/home/$user" ]; then # 홈 디렉토리가 있는 사용자만 확인
		last_change=$(chage -l $user 2>/dev/null | grep "Last password change" | awk -F: '{print $4}')
		if [ -n "$last_change" ]; then 
			echo "$user: $last_change"
		else 
			echo "$user: 정보 없음"
		fi
	fi
done 

echo 

# 사용자 이름 입력
read -p "비밀번호 변경 날짜를 설정할 사용자 이름을 입력하세요 : " username

# 입력한 사용자 이름 재확인
read -p "입력한 사용자 이름 : $username. 정말로 바꾸시겠습니까? (y/n) : " confirmation

if [[ $confirmation != "y" ]]; then
	echo "작업이 취소되었습니다."
	exit 1
fi

# 현재 날짜를 YYYY-MM-DD 형식으로 구합니다. 
current_date=$(date +%Y-%m-%d)

# chage 명령어를 사용하여 비밀번호 변경 날짜를 현재 날짜로 설정합니다. 
chage -d $current_date $username

# 결과 메시지를 출력합니다. 
if [ $? -eq 0 ]; then 
	echo "사용자 $username의 비밀번호 변경 날짜가 $current_date로 설정되었습니다."
else
	echo "사용자 $username의 비밀번호 변경 날짜를 설정하는데, 실패했습니다."
fi
