#!/bin/bash
USER=$1
PASSWORD=$2
OTP=$3
ZIP_FILE_NAME=$4
PARENT_DIR=$5
CODE_NAME=$6
VERSION_FILE=$7
SLACK_CHANNEL=$8

NOT_DEPLOYED_HOST=()
NOT_INSTALLED_HOST=()
for HOST in `cat .tailscale-ip`
do
	echo "hostname: $HOST"

	# 1. deploy - scp로 zip 패키지 전송
	action/deploy.exp $USER $HOST $PASSWORD $OTP $ZIP_FILE_NAME > /dev/null
	sleep 10
	# 1-1. deploy check
	action/deploy-check.exp $USER $HOST $PASSWORD $OTP $ZIP_FILE_NAME > deploy_check_$HOST.txt
	sleep 10
	action/deploy-check.sh $HOST $ZIP_FILE_NAME
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
		sleep 10
		action/install-check.sh $HOST $VERSION_FILE
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
	deploy_result_message="Deploy와 Install에 모두 성공하였습니다"
	exitcode=0
else
	deploy_result_message="Deploy와 Install에 실패한 기기들의 hostname은 다음과 같습니다  
		Deploy: ${NOT_DEPLOYED_HOST[@]}  
		Install: ${NOT_INSTALLED_HOST[@]}"
	exitcode=1
fi
source /etc/profile
slackboy send --message “${deploy_result_message}” --channel ${SLACK_CHANNEL}

exit $exitcode