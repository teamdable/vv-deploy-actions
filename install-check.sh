#!/bin/bash
HOST=$1
VERSION_FILE=$2

if [[ -z `grep "version" version_check_$HOST.txt` ]]
then 
	echo "배포 대상 edge device의 version 파일을 읽어올 수 없습니다."
	exit 1
fi

source_version=`cat $VERSION_FILE | awk '{print $3}'`
if [[ $VERSION_FILE == "package.json" ]]
then
	target_version=`grep "version" version_check_$HOST.txt | awk '{print $2}' | tr -d ","`
elif  [[ $VERSION_FILE == ".version" || "_version.py" ]]
then
	target_version=`grep "__version__" version_check_$HOST.txt | awk '{print $3}'`
fi

if [[ $source_version == $target_version ]]
then
	echo "install Success"
	exit 0
else
	echo "source version: $source_version, target version: $target_version"
	echo "[err] target version과 source version이 일치하지않습니다"
	exit 1
fi
