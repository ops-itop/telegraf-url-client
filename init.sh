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
telegraf_conf="url.conf"
node="$1"
rootdir=`grep "rootdir = " $conf |awk '{print $NF}'`
repo_urls=`grep "giturl = " $conf |awk '{print $NF}'`
urls_dir=`echo $repo_urls |awk -F'/' '{print $NF}' |cut -f1 -d'.'`
telegraf=`grep "telegraf = " $conf |awk '{print $NF}'`
telegraf_dir=`echo $telegraf |awk -F'/' '{print $NF}' |cut -f1 -d'.'`
influxdb=`grep "influxdb = " $conf |awk '{print $NF}'`
interval=`grep "interval" $conf |awk '{print $NF}'`
cron="telegraf-cron.sh"

echo $rootdir

[ ! -d $rootdir ] && mkdir $rootdir
cp $telegraf_conf $rootdir
cp $cron $rootdir

cat >$rootdir/$conf <<EOF
rootdir = $rootdir
giturl = $repo_urls
node = $node
EOF

cd $rootdir
if [ -d $telegraf_dir ];then
	cd $telegraf_dir
	git pull
	cd ../
else
	git clone $telegraf
fi

[ -f telegraf.pid ] && kill -9 `cat telegraf.pid`
rm -f telegraf
cp $telegraf_dir/telegraf ./
chmod +x telegraf

# 修改配置文件 url.conf
sed -i "s/monitor_node =.*/monitor_node = \"$node\"/g" $telegraf_conf
sed -i "s#urls = \[.*#urls = \[\"$influxdb\"\]#g" $telegraf_conf

if [ -d $urls_dir ];then
	cd $urls_dir
	git pull
	cd ../
else
	git clone $repo_urls
fi

./telegraf -config $rootdir/url.conf -config-directory $rootdir/$urls_dir/$node -pidfile $rootdir/telegraf.pid &>>$rootdir/telegraf.log &


# 修改cron
sed -i "/$cron/d" /etc/crontab
sed -i "/telegraf-cron/d" /etc/crontab
cat >>/etc/crontab<<EOF

# telegraf-cron 定时pull git repo,更新telegraf配置文件
*/$interval * * * * root $rootdir/$cron &> $rootdir/cron.log
EOF

