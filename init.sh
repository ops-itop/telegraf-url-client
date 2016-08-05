#!/bin/bash

############################
# Usage:
# File Name: init.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2016-08-05 16:59:04
############################

[ $# -lt 1 ] && echo "$0 monit_node_name(China,UnitedStates,HongKong" && exit 1
conf="conf.ini"
node="$1"
rootdir=`grep "rootdir = " $conf |awk '{print $NF}'`
repo_urls=`grep "giturl = " $conf |awk '{print $NF}'`
urls_dir=`echo $repo_urls |awk -F'/' '{print $NF}' |cut -f1 -d'.'`
telegraf=`grep "telegraf = " $conf |awk '{print $NF}'`
telegraf_dir=`echo $telegraf |awk -F'/' '{print $NF}' |cut -f1 -d'.'`
echo $rootdir

[ ! -d $rootdir ] && mkdir $rootdir

cd $rootdir
if [ -d $telegraf_dir ];then
	cd $telegraf_dir
	git pull
	cd ../
else
	git clone $telegraf
fi

cp $telegraf_dir/telegraf ./
chmod +x telegraf
./telegraf -sample-config -input-filter url_monitor -output-filter influxdb > url.conf

if [ -d $urls_dir ];then
	cd $urls_dir
	git pull
	cd ../
else
	git clone $repo_urls
	git checkout $node
fi

./telegraf -config $rootdir/url.conf -config-directory $rootdir/$urls_dir/$node -pidfile $rootdir/telegraf.pid &>>$rootdir/telegraf.log &
