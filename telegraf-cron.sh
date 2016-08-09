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

cd $rootdir/$urls_dir
git pull |grep -E "$node/[0-9]{1,}\.conf" &>/dev/null && r=1 || r=0

cd ../
if [ $r -eq 1 ];then
	kill -HUP `cat telegraf.pid`
fi
