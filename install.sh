#!/bin/bash

usage='
usage : install.sh --host { HOST } --user { USER } --password { PASSWORD }
 --otp { OTP } --zip-file-name { ZIP_FILE_NAME } --parent-dir { PARENT_DIR } --code-name { CODE-NAME }
 '
LONG=host:,user:,password:,otp:,zip-file-name:,version-file:,parent-dir:,code-name:,help
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
		echo "인자전달이 잘못되었습니다. 사용예시를 확인해주세욧"
		echo "$usage"
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
	--help)
		echo "$usage"
		exit 0
		;;
	--)
		shift
		break
		;;
	esac
done


# install - edge서버에서 해당 모듈을 사용할 수 있도록 압축 해제 & 패키지 설치
action/install.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$ZIP_FILE_NAME" "$PARENT_DIR" "$CODE_NAME" > install_check_$HOST.txt
#sleep 10
## install check
#action/install-check.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$PARENT_DIR" "$CODE_NAME" "$VERSION_FILE" > version_check_$HOST.txt
#action/install-check.sh --host "$HOST" --version-file "$VERSION_FILE"
install_result=$?

if [[ $install_result -eq 1 ]]
then
	echo "install 작업에 실패했습니다"
	exit 1
fi