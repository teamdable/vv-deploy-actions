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
	--)
		shift
		break
		;;
	esac
done

echo "$VPN_IP"

# /tmp 디렉토리 scp 전달 + unzip

# kill

# deploy

# start

# exitcode
