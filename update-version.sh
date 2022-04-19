#!/bin/bash
LONG=code-name:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다. "
    exit 1
}
eval set -- "$OPTS"

while [[ $# -gt 0 ]]
do
	case "$1" in
	--code-name)
		CODE_NAME=$2
		shift 2
		;;
	--)
		shift
		break
		;;
	esac
done

UPDATE_VERSION=`cat only-version`
sed -i "s/$CODE_NAME: [0-9]\+\.[0-9]\+\.[0-9]\+[(a|b|rc)]*[0-9]*/$CODE_NAME: $UPDATE_VERSION/g" ~/.metadata