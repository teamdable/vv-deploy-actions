#!/bin/bash

# 인자받는 부분
LONG=vpn_ip:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다. "
    exit 1
}
eval set -- "$OPTS"

while [[ $# -gt 0 ]]
do
	case "$1" in
	--vpn_ip)
		VPN_IP=$2
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
#	--parent-dir)
#		PARENT_DIR=$2
#		shift 2
#		;;
#	--code-name)
#		CODE_NAME=$2
#		shift 2
#		;;
#	--version-file)
#		VERSION_FILE=$2
#		shift 2
#		;;
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

echo "$VPN_IP"

# /tmp 디렉토리 scp 전달 + unzip

echo "hostname: $HOST"

	# 1. deploy - scp로 zip 패키지 전송
	action/deploy.exp $USER $VPN_IP $PASSWORD $OTP $ZIP_FILE_NAME > /dev/null
# kill

# deploy

# start

# exitcode
