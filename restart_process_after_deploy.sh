#!/bin/bash
USER=$1
PASSWORD=$2
OTP=$3
PARENT_DIR=$4
CODE_NAME=$5

NOT_KILLED_HOST=()
NOT_STARTED_HOST=()
for HOST in `cat .tailscale-ip`
do
	echo "hostname: $HOST"

  # 1. 프로세스 끄기
  action/kill_process.exp $USER $HOST $PASSWORD $OTP $PARENT_DIR $CODE_NAME
  result=$?

  if [[ $result -eq 1 ]]
  then
    NOT_KILLED_HOST+=( $HOST )
  fi
  echo -e "\n"

  sleep 5
  # 2. 프로세스 켜기
  action/start_process.exp $USER $HOST $PASSWORD $OTP $PARENT_DIR $CODE_NAME
  result=$?

  if [[ $result -eq 1 ]]
  then
    NOT_STARTED_HOST+=( $HOST )
  fi
	echo -e "\n"
done

if [[ -z ${NOT_KILLED_HOST} && -z ${NOT_STARTED_HOST} ]]
then
	echo "모든 기기의 $CODE_NAME 재시작을 성공하였습니다"
else
	echo "Kill, Start 프로세스에 실패한 기기의 hostname은 다음과 같습니다"
	echo "Kill: ${NOT_KILLED_HOST[@]}"
	echo "Start: ${NOT_STARTED_HOST[@]}"
	exit 1
fi