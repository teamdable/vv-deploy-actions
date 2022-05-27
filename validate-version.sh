#!/bin/bash

usage='
validate-version.sh --host { HOST }  --user { USER } --password { PASSWORD }
--otp { OTP } --code-name { CODE-NAME }
'

LONG=host:,user:,password:,otp:,code-name:,slack-channel:,version-file-name:,parent-dir:,help
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
		echo "인자전달이 잘못되었습니다. 사용예시를 확인해주세요"
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
	--code-name)
		CODE_NAME=$2
		shift 2
		;;
	--slack-channel)
		SLACK_CHANNEL=$2
		shift 2
		;;
  --version-file-name)
    VERSION_FILE_NAME=$2
    shift 2
    ;;
  --parent-dir)
    PARENT_DIR=$2
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

target_version_raw=$(action/read-edge-version.exp "$USER" "$HOST" "$PASSWORD" "$OTP" "$PARENT_DIR" "$CODE_NAME" "$VERSION_FILE_NAME" )
echo "read result $target_version_raw"
#readarray -t target_version_split<<<"$target_version_raw"
#target_version_raw=$(echo "${target_version_split[-2]}")
#echo "split last index $target_version_raw"
source_version_raw=$(cat "$VERSION_FILE_NAME" )
source_version_split=("${source_version_raw}")
source_version_raw=$(echo "${source_version_split[-1]}")
action/compare-raw-versions.sh --version-file "$VERSION_FILE_NAME" --source-version-raw "$source_version_raw" --target-version-raw "$target_version_raw"
