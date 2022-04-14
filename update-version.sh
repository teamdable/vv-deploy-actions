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


if [[ $CODE_NAME == "edge-player" ]]
then
	MODULE_NAME="edge-player"
elif [[ $CODE_NAME == "resource" ]]
then
	MODULE_NAME="resource-monitoring"
elif [[ $CODE_NAME == "process" ]]
then
	MODULE_NAME="process-monitoring"
elif [[ $CODE_NAME == "vv-yolor" ]]
then
	MODULE_NAME="inference"
elif [[ $CODE_NAME == "vv-edge-setup" ]]
then
	MODULE_NAME=$CODE_NAME
fi
UPDATE_VERSION=`cat only-version`
sed -i "s/$MODULE_NAME: [0-9]\+\.[0-9]\+\.[0-9]\+[(a|b|rc)]*[0-9]*/$MODULE_NAME: $UPDATE_VERSION/g" ~/.metadata