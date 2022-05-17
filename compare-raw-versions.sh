#!/bin/bash
LONG=version-file:,source-version-raw:,target-version-raw:
OPTS=$(getopt -o '' -a --longoptions $LONG  -- "$@")
[ $? -eq 0 ] || {
    echo "인자전달이 잘못되었습니다. "
    exit 1
}
eval set -- "$OPTS"

while [[ $# -gt 0 ]]
do
	case "$1" in
	--version-file)
	  VERSION_FILE=$2
	  shift 2
	  ;;
	--source-version-raw)
		SOURCE_VERSION_RAW=$2
		shift 2
		;;
  --target-version-raw)
		TARGET_VERSION_RAW=$2
		shift 2
		;;
	--)
		shift
		break
		;;
	esac
done

extract_version_from_raw() {
	local version_raw=$1
	version=$(echo "$version_raw" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+[(a|b|rc)]?[0-9]*")
	if [[ -z $version ]]
	then
		echo "version 파일을 읽어올 수 없습니다. $version"
		exit 1
	fi

	echo "$version"
}

if [[ $VERSION_FILE == "package.json" ]]
then
	version_key_string="\"version\""
elif [[ $VERSION_FILE = ".version" ]] || [[ $VERSION_FILE = "_version.py" ]]
then
	version_key_string="__version__"
else
	echo "$VERSION_FILE 버전 메타데이터는 지원하지 않습니다"
	exit 1
fi

source_version=$(extract_version_from_raw "$SOURCE_VERSION_RAW")
target_version=$(extract_version_from_raw "$TARGET_VERSION_RAW")
echo "Source version: $source_version, Target version: $target_version"

if [[ $source_version == "$target_version" ]]
then
	echo "버전체크를 성공적으로 완료했습니다"
	exit 0
else
	echo "[err] target version과 source version이 일치하지않습니다"
	exit 1
fi
