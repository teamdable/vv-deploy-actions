#!/bin/bash
LONG=user:,password:,otp:,process-name:,slack-notice,slack-channel:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다."
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
  --slack-notice)
    SLACK_NOTICE=true
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

# 슬랙 알림 조건 확인 하기
if [[ -n $SLACK_NOTICE && -z $SLACK_CHANNEL ]]
then
  echo "slack-notice를 설정했지만 slack-channel의 정보가 없습니다"
  exit 1
elif [[ -z $SLACK_NOTICE && -n $SLACK_CHANNEL ]]
then
  SLACK_NOTICE=true
fi

vpn_ip_to_device_id() {
	TARGET_HOSTS_VPN_IP=$1
  DEVICE_ID=$(edge-info-search --query vpn_ip=="$TARGET_HOSTS_VPN_IP" -c device_id)
	echo "${TARGET_DEVICES_ID[@]}"
}

for HOST in $(cat .tailscale-ip)
do
	echo "hostname: $HOST"

  # 프로세스 끄기
  action/kill-process.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$PROCESS_NAME"
  kill_result=$?
  echo -e "\n"

done

# 결과 메세지 처리
DEVICE_ID=$(vpn_ip_to_device_id "${HOST[@]}")
if [[ $kill_result == 0 ]]
then
  deploy_result_message="DEVICE $DEVICE_ID 의 $PROCESS_NAME 종료에 성공했습니다"
  exitcode=0
else
  deploy_result_message="DEVICE $DEVICE_ID 의 $PROCESS_NAME 종료에 실패했습니다"
  exitcode=1
fi
echo "$deploy_result_message"

if [[ $SLACK_NOTICE ]]
then
  source /etc/profile
  slackboy send --message "${deploy_result_message}" --channel "${SLACK_CHANNEL}" --prefix cd-restart-process
fi
exit $exitcode