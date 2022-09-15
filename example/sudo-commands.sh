#!/bin/bash
# edge-device에 아래와같이 password를 넘겨받아서, 
# sudo권한으로 원하는 커맨드를 실행하는 스크립트를 생성하세요.
PASSWD=$1

echo $PASSWD | sudo -S apt -y purge update-notifier
