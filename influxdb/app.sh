#!/bin/sh

exec /usr/bin/influxd -config $APP_CONFIG_PATH/INFLUXDB
