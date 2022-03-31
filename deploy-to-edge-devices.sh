#!/bin/bash
LONG=user:,password:,otp:,zip-file-name:,parent-dir:,code-name:,version-file:,slack-channel:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다. "
    exit 1
}
eval set -- "$OPTS"

while [[ $# -gt 0 ]]
do
	case "$1" in
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
	--slack-channel)
		SLACK_CHANNEL=$2
		shift 2
		;;
	--)
		shift
		break
		;;
	esac
done

vpn_ip_to_device_id() {
	TARGET_HOSTS_VPN_IP=$@
	
	TARGET_DEVICES_ID=()
	for HOST in $TARGET_HOSTS_VPN_IP
	do
		DEVICE_ID=`edge-info-search --query vpn_ip==$HOST -c device_id`
		TARGET_DEVICES_ID+=( $DEVICE_ID )
	done
	echo ${TARGET_DEVICES_ID[@]}
}

source /etc/profile

DEPLOY_TARGET_DEVICES=()
NOT_DEPLOYED_HOST=()
NOT_INSTALLED_HOST=()
NOT_DEPLOYED_DEVICES=()
NOT_INSTALLED_DEVICES=()

# 'Deploy & Install' step 시작시 슬랙 메세지 전송
deploy_target_vpn_ips=`cat .tailscale-ip`
DEPLOY_TARGET_DEVICES=`vpn_ip_to_device_id $deploy_target_vpn_ips`
deploy_start_message="$CODE_NAME 배포가 시작됩니다. 배포 작업 종료시까지 아래 장비들에 접속이 금지됩니다.
	Device: `echo ${DEPLOY_TARGET_DEVICES[@]}| sed 's/ /\,  /g'`"

slackboy send --message "${deploy_start_message}" --channel "${SLACK_CHANNEL}" --prefix "deploy-process" > /dev/null

for HOST in `cat .tailscale-ip`
do
	echo "hostname: $HOST"

	# 1. deploy - scp로 zip 패키지 전송
	action/deploy.exp $USER $HOST $PASSWORD $OTP $ZIP_FILE_NAME > /dev/null
	sleep 10
	# 1-1. deploy check
	action/deploy-check.exp $USER $HOST $PASSWORD $OTP $ZIP_FILE_NAME > deploy_check_$HOST.txt
	sleep 10
	action/deploy-check.sh --host $HOST --zip-file-name $ZIP_FILE_NAME
	result=$?

	if [[ $result -eq 1 ]]
	then
		NOT_DEPLOYED_HOST+=( $HOST )
		NOT_INSTALLED_HOST+=( $HOST )
	else
		# 2. install - edge서버에서 해당 모듈을 사용할 수 있도록 압축 해제 & 패키지 설치
		action/install.exp $USER $HOST $PASSWORD $OTP $ZIP_FILE_NAME $PARENT_DIR $CODE_NAME > install_check_$HOST.txt
		sleep 10
		# 2-2. install check 
		action/install-check.exp $USER $HOST $PASSWORD $OTP $PARENT_DIR $CODE_NAME $VERSION_FILE > version_check_$HOST.txt
		action/install-check.sh --host $HOST --version-file $VERSION_FILE
		result=$?

		if [[ $result -eq 1 ]]
		then
			NOT_INSTALLED_HOST+=( $HOST )
		fi
	fi
	echo -e "\n"
done

if [[ -z ${NOT_DEPLOYED_HOST} && -z ${NOT_INSTALLED_HOST} ]]
then
	deploy_result_message="$CODE_NAME의 Deploy와 Install에 모두 성공하였습니다."
	exitcode=0
else
	NOT_DEPLOYED_DEVICES=`vpn_ip_to_device_id ${NOT_DEPLOYED_HOST[@]}`
	NOT_INSTALLED_DEVICES=`vpn_ip_to_device_id ${NOT_INSTALLED_HOST[@]}`

	deploy_result_message=":rotating_light:error:rotating_light: $CODE_NAME의 Deploy와 Install에 실패한 기기들의 디바이스는 다음과 같습니다.
	Deploy: `echo ${NOT_DEPLOYED_DEVICES[@]} | sed 's/ /\,  /g'`
	Install: `echo ${NOT_INSTALLED_DEVICES[@]} | sed 's/ /\,  /g'`"
	exitcode=1
fi
echo $deploy_result_message
slackboy send --message "${deploy_result_message}" --channel ${SLACK_CHANNEL} --prefix "deploy-process" > /dev/null

exit $exitcode