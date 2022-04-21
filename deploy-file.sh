#!/bin/bash

LONG=host:,user:,password:,otp:,zip-file-name:
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
	--)
		shift
		break
		;;
	esac
done

echo "hostname: $HOST"

action/deploy.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" > /dev/null

##  deploy check
#action/deploy-check.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" > deploy_check_$HOST.txt
#sleep 10
#action/deploy-check.sh --host "$HOST" --zip-file-name "$ZIP_FILE_NAME"
deploy_result=$?

if [[ $deploy_result -eq 1 ]]
then
  echo "파일전송에 실패했습니다"
  exit 1
fi