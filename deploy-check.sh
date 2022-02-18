#!/bin/bash
HOST=$1
ZIP_FILE_NAME=$2

# TODO: 더 깔끔하게 txt 파일에서 에러 확인하는 방법으로 변경
if ! [[ -z `grep "/tmp/$ZIP_FILE_NAME exist" deploy_check_$HOST.txt` ]]
then
		echo "build & deploy Success"
		exit 0
else
		echo "[err] 배포 대상 edge device에 deploy 작업이 제대로 이루어지지않았습니다"
		exit 1
fi
