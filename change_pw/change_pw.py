# -*- coding: utf-8 -*-
import os
import subprocess
import re
from datetime import datetime

def get_users_with_uid_above_1000():
    # /etc/passwd 에서 UID가 1000 초과인 사용자 목록을 가져옵니다.
    users = []
    try:
        with open("/etc/passwd", "r") as f:
            for line in f:
                parts = line.split(":")
                uid = int(parts[2])
                if uid > 1000:
                    users.append(parts[0])
                    
    except Exception as e:
        print("Error reading /etc/passwd: {}".format(e))
    
    return users 
    
def get_last_password_change(user):
    # chage 명령어를 사용하여 비밀번호 변경 날짜를 가져옵니다.
    try:
        result = subprocess.run(
            ["chage", "-l", user], capture_output=True, text=True, check=True
        )
        # Last password change" 부분을 찾아서 비밀번호 변경 날짜를 추출합니다.
        match = re.search(r"Last password change\s*:\s*(.*)", result.stdout)
        
        if match:
            return match.group(1).strip()
            
        else:
            return None
            
    except subprocess.CalledProcessError as e:
        return None 

def main():
    # 1. UID가 1000 초과인 사용자 목록을 가져옵니다.
    users = get_users_with_uid_above_1000()
    print("현재 비밀번호 변경 날짜 (root 및 UID가 1000 초과인 사용자) : ")
    
    # 2. 각 사용자의 비밀번호 변경 날짜를 출력합니다.
    for user in users:
        if os.path.isdir(f"/home/{user}"):  # 홈 디렉토리가 있는 사용자만 확인
            last_change = get_last_password_change(user)
            if last_change:
                print("{} : {}".format(user, last_change))
            else:
                print("{} : 정보 없음".format(user))
                
    print()
    
    # 3. 사용자 이름 입력 받기
    username = input("비밀번호 변경 날짜를 설정할 사용자 이름을 입력하세요 : ")
    
    # 4. 사용자 입력 확인
    confirmation = input("입력한 사용자 이름 : {}. 정말로 바꾸시겠습니까? (y/n) : ".format(username))
    if confirmation.lower() != "y":
        print("작업이 취소되었습니다.")
        return 
        
    # 5. 현재 날짜를 YYYY-MM-DD 형식으로 구합니다.
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    # 6. chage 명령어를 사용하여 비밀번호 변경 날짜를 현재 날짜로 설정합니다.
    try:
        subprocess.run(["chage", "-d", current_date, username], check=True)
        print("사용자 {}의 비밀번호 변경 날짜가 {}로 설정되었습니다.".format(username, current_date))
    except subprocess.CalledProcessError as e:
        print("사용자 {}의 비밀번호 변경 날짜를 설정하는데 실패했습니다.".format(username))
        
if __name__ == "__main__": 
    main()
