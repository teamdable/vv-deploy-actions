#!/bin/bash
LONG=host:,zip-file-name:
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

if ! [[ -z $(grep "/tmp/$ZIP_FILE_NAME exist" deploy_check_$HOST.txt) ]]
then
		echo "build & deploy Success"
		exit 0
else
		echo "[err] 배포 대상 edge device에 deploy 작업이 제대로 이루어지지않았습니다"
		exit 1
fi
