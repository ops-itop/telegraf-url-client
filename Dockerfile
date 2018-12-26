FROM registry-cn.scloud.letv.com/hean/golang-dev:latest as builder
RUN mkdir $GOPATH/src/github.com/influxdata
WORKDIR $GOPATH/src/github.com/influxdata
RUN git clone -b 1.0.0 --depth=1 https://github.com/ops-itop/telegraf
RUN git clone https://github.com/annProg/url_monitor telegraf/plugins/inputs/url_monitor
RUN sed -i 's/http_response/url_monitor/g' telegraf/plugins/inputs/all/all.go
WORKDIR telegraf
RUN make prepare
RUN make build
