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
testurl=`grep "testurl" $conf |awk '{print $NF}'`
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
rm -f telegraf.pid
cp $telegraf_dir/telegraf ./
chmod +x telegraf

# 修改配置文件 url.conf
sed -i "s/monitor_node =.*/monitor_node = \"$node\"/g" $telegraf_conf
sed -i "s#urls = \[.*#urls = \[\"$influxdb\"\]#g" $telegraf_conf
sed -i "s#address = .*#address = \"$testurl\"#g" $telegraf_conf

if [ -d $urls_dir ];then
	cd $urls_dir
	git pull
	cd ../
else
	git clone $repo_urls
fi

cat >control<<EOF
#!/bin/bash
[ \$# -lt 1 ] && echo "\$0 (start|stop|restart|reload|status)"

function start()
{
	[ -f $rootdir/telegraf.pid ] && echo "$rootdir/telegraf.pid exists!" && exit 1
	$rootdir/telegraf -config $rootdir/url.conf -config-directory $rootdir/$urls_dir/$node -pidfile $rootdir/telegraf.pid &>>$rootdir/telegraf.log &
}

function stop()
{
	kill -INT \`cat $rootdir/telegraf.pid\`
	rm -f $rootdir/telegraf.pid
}

function status()
{
	if [ ! -f $rootdir/telegraf.pid ];then
		echo "telegraf is not running"
		exit 1
	fi

	pid=\`ps aux |grep "$rootdir" |grep "telegraf" |grep -v "grep" |awk '{print \$2}' |head -n 1\`
	fpid=\`cat $rootdir/telegraf.pid\`
	if [ "\$pid"x == "\$fpid"x ];then
		echo "telegraf is running(\$pid)"
	else
		echo "telegraf is dead but pid file exists"
	fi
}

function restart()
{
	stop
	start
}

function reload()
{
	kill -HUP \`cat $rootdir/telegraf.pid\`
}

case \$1 in
	start) start;;
	stop) stop;;
	restart) restart;;
	reload) reload;;
	status) status;;
	*) exit 1;;
esac
EOF

# 修改cron
sed -i "/$cron/d" /etc/crontab
sed -i "/telegraf-cron/d" /etc/crontab
cat >>/etc/crontab<<EOF

# telegraf-cron 定时pull git repo,更新telegraf配置文件
*/$interval * * * * root $rootdir/$cron &>> $rootdir/cron.log
EOF

chmod +x control
./control status
./control start
sleep 5
./control status
