#!/bin/bash
LONG=user:,password:,otp:,process-name:,slack-channel:
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
	--process-name)
		PROCESS_NAME=$2
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

NOT_KILLED_HOST=()
NOT_STARTED_HOST=()
for HOST in `cat .tailscale-ip`
do
	echo "hostname: $HOST"

  # 1. 프로세스 끄기
  action/kill-process.exp $USER $HOST $PASSWORD $OTP $PROCESS_NAME
  result=$?
  if [[ $result -gt 0 ]]
  then
    NOT_KILLED_HOST+=( $HOST )
  fi
  echo -e "\n"

  sleep 5
  # 2. 프로세스 켜기
  action/start-process.exp $USER $HOST $PASSWORD $OTP $PROCESS_NAME
  result=$?
  if [[ $result -gt 0 ]]
  then
    NOT_STARTED_HOST+=( $HOST )
  fi
	echo -e "\n"
done

if [[ -z ${NOT_KILLED_HOST} && -z ${NOT_STARTED_HOST} ]]
then
	deploy_result_message="모든 기기의 $PROCESS_NAME 재시작을 성공하였습니다"
  exitcode=0
else
  NOT_KILLED_DEVICES=`vpn_ip_to_device_id ${NOT_DEPLOYED_HOST[@]}`
  NOT_STARTED_DEVICES=`vpn_ip_to_device_id ${NOT_INSTALLED_HOST[@]}`
  deploy_result_message="Kill, Start $PROCESS_NAME 명령에 실패한 기기의 디바이스는 다음과 같습니다
		Kill: ${NOT_KILLED_DEVICES[@]}
		Start: ${NOT_STARTED_DEVICES[@]}"
	exitcode=1
fi
echo $deploy_result_message

source /etc/profile
slackboy send --message "${deploy_result_message}" --channel ${SLACK_CHANNEL} --prefix CD-restart-process

exit $exitcode