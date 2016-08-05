#!/bin/bash

############################
# Usage:
# File Name: cron.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2016-08-04 22:18:47
############################

conf="conf.ini"
rootdir=`grep "rootdir = " $conf |awk '{print $NF}'`
repo_urls=`grep "giturl = " $conf |awk '{print $NF}'`
urls_dir=`echo $repo_urls |awk -F'/' '{print $NF}' |cut -f1 -d'.'`

cd $rootdir/$urls_dir
git pull |grep "Already up-to-date." &>/dev/null && r=1 || r=0

if [ $r -eq 0 ];then
	kill -HUP `cat telegraf.pid`
fi
