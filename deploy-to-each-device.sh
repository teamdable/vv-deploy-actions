#!/bin/bash

LONG=host:,user:,password:,otp:,zip-file-name:,version-file:,parent-dir:,code-name:,process-name:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다. "
    exit 1
}
eval set -- "$OPTS"

while [[ $# -gt 0 ]]
do
	case "$1" in
	--host)
		HOST=$2
		shift 2
		;;
  --user)
		USER=$2
		shift 2
		;;
	--password)
		PASSWORD=$2
		shift 2
		;;
	--otp)
		OTP=$2
		shift 2
		;;
	--zip-file-name)
		ZIP_FILE_NAME=$2
		shift 2
		;;
	--parent-dir)
		PARENT_DIR=$2
		shift 2
		;;
	--code-name)
		CODE_NAME=$2
		shift 2
		;;
	--version-file)
		VERSION_FILE=$2
		shift 2
		;;
  --process-name)
    PROCESS_NAME=$2
    shift 2
    ;;
#	--slack-channel)
#		SLACK_CHANNEL=$2
#		shift 2
#		;;
	--)
		shift
		break
		;;
	esac
done


echo "hostname: $HOST"

action/deploy.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" > /dev/null

## 1-1. deploy check
#action/deploy-check.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" > deploy_check_"$HOST".txt
#sleep 10
#action/deploy-check.sh --host "$HOST" --zip-file-name "$ZIP_FILE_NAME"
deploy_result=$?

if [[ $deploy_result -eq 1 ]]
then
  echo "1단계 전송작업에 실패했습니다"
  exit 1
fi

#  프로세스 끄기
action/kill-process.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$PROCESS_NAME"
result=$?
if [[ $result -gt 0 ]]
then
  echo "2단계 프로세스종료 작업에 실패했습니다"
  exit 1
fi

# 2. install - edge서버에서 해당 모듈을 사용할 수 있도록 압축 해제 & 패키지 설치
action/install.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" "$PARENT_DIR" "$CODE_NAME" > install_check_$HOST.txt
sleep 10
# 2-2. install check
#action/install-check.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$PARENT_DIR" "$CODE_NAME" "$VERSION_FILE" > version_check_$HOST.txt
#action/install-check.sh --host "$HOST" --version-file "$VERSION_FILE"
install_result=$?

if [[ $install_result -eq 1 ]]
then
  echo "3단계 install 작업에 실패했습니다"
  exit 1
fi

# 프로세스 시작
action/start-process.exp $USER $HOST $PASSWORD $OTP $PROCESS_NAME
result=$?
if [[ $result -gt 0 ]]
then
  echo "4단계 프로세스 실행 작업에 실패했습니다"
  exit 1
fi

echo -e "\n"
echo "모든 배포작업이 성공했습니다"
exit 0
