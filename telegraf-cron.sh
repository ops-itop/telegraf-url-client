#!/bin/bash

############################
# Usage:
# File Name: cron.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2016-08-04 22:18:47
############################

basedir=$(cd `dirname $0`; pwd)
cd $basedir
conf="conf.ini"
rootdir=`grep "rootdir = " $conf |awk '{print $NF}'`
repo_urls=`grep "giturl = " $conf |awk '{print $NF}'`
urls_dir=`echo $repo_urls |awk -F'/' '{print $NF}' |cut -f1 -d'.'`
node=`grep "node = " $conf | awk '{print $NF}'`

# 判断telegraf是否在运行
ps aux |grep telegraf |grep -v "grep" && st=1 || st=0
#./control status |grep "is running" && st=1 || st=0
if [ $st -eq 0 ];then
	rm -f telegraf.pid
	./control start
	sleep 3
	./control status
fi

cd $rootdir/$urls_dir

git pull 2>&1 |grep -E "$node/[0-9]{1,}\.conf" && r=1 || r=0

cd ../
if [ $r -eq 1 ];then
	kill -HUP `cat telegraf.pid`
fi

