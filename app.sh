#!/bin/sh

URL_CONF_DIR="/telegraf-url"
PID="/run/telegraf.pid"
git clone $GIT_REPO $URL_CONF_DIR

# cron
cat > /cron.sh <<EOF
#!/bin/sh
cd $URL_CONF_DIR
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
git pull 2>&1 |grep -E "$NODE/[0-9]{1,}\.conf" && r=1 || r=0
echo "[Cron \`date\`]git pull result: r=\$r"
if [ \$r -eq 1 ];then
	kill -HUP \`cat $PID\`
fi
EOF
chmod +x /cron.sh
echo "*/2 * * * * /cron.sh &>/tmp/cron.log" >> /etc/crontabs/root

crond
exec /telegraf -config $APP_CONFIG_PATH/TELEGRAF_CONFIG -config-directory $URL_CONF_DIR/$NODE -pidfile $PID
