FROM registry-cn.scloud.letv.com/hean/golang-dev:latest as builder
RUN mkdir $GOPATH/src/github.com/influxdata
WORKDIR $GOPATH/src/github.com/influxdata
RUN git clone -b 1.0.0 --depth=1 https://github.com/ops-itop/telegraf
RUN git clone https://github.com/annProg/url_monitor telegraf/plugins/inputs/url_monitor
WORKDIR telegraf
COPY conf/inputs_all.go plugins/inputs/all/all.go
COPY conf/outputs_all.go plugins/outputs/all/all.go
RUN make prepare
RUN make build

FROM alpine:3.8
COPY --from=builder /go/bin/telegraf /telegraf
