#!/usr/bin/env bash
# code repo의 root dir/bin/deploy/install-setting.sh
# 배포 후 해당 코드 모듈을 실행하기 위한 dependency packages 설치, pyenv 설정등을 해당 쉘 스크립트에서 관리한다.

PASSWD=$1

# sudo권한이 필요한 경우
echo $PASSWD | sudo -S bash setting1
bash setting2.sh
 
result=$?
if [[ $result -eq 0 ]]
then
	echo "setting이 완료되었습니다"
	exitcode=0
else
	echo "[err] setting이 실패했습니다"
	exitcode=1
fi
exit $exitcode