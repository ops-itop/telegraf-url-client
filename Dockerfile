FROM registry.cn-beijing.aliyuncs.com/kubebase/golang-builder:latest as builder
RUN mkdir -p $GOPATH/src/github.com/influxdata
WORKDIR $GOPATH/src/github.com/influxdata
RUN git clone -b 1.0.0 --depth=1 https://github.com/ops-itop/telegraf
RUN git clone https://github.com/annProg/url_monitor telegraf/plugins/inputs/url_monitor
WORKDIR telegraf
COPY conf/inputs_all.go plugins/inputs/all/all.go
COPY conf/outputs_all.go plugins/outputs/all/all.go
RUN go get github.com/sparrc/gdm
RUN /go/bin/gdm restore
RUN go install -ldflags="-X main.version=1.0.0"

FROM alpine:3.8
RUN apk add --no-cache git
COPY --from=builder /go/bin/telegraf /telegraf
COPY app.sh /app.sh
CMD ["sh", "/app.sh"]
