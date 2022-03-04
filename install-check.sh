#!/bin/bash
HOST=$1
VERSION_FILE=$2

extract_version() {
	local check_file=$1
	
	raw_version_data=`grep $version_key_string $check_file`
	if [[ -z $raw_version_data ]]
	then
		echo "배포 대상 edge device의 version 파일을 읽어올 수 없습니다."
		exit 1
	fi
	version=`echo $raw_version_data | sed 's/[^a0-9.]//g'`
	echo $version
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
source_version=`extract_version $VERSION_FILE`
target_version=`extract_version version_check_$HOST.txt`
echo "source version: $source_version, target version: $target_version"

if [[ $source_version == $target_version ]]
then
	echo "install Success"
	exit 0
else
	echo "[err] target version과 source version이 일치하지않습니다"
	exit 1
fi
