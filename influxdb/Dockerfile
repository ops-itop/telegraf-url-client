FROM registry.cn-beijing.aliyuncs.com/kubebase/golang-builder:latest as builder
ENV VERSION 1.0
RUN mkdir -p $GOPATH/src/github.com/influxdata
WORKDIR $GOPATH/src/github.com/influxdata
RUN git clone -b $VERSION --depth=1 https://github.com/ops-itop/influxdb
WORKDIR influxdb
RUN make tools
RUN /go/bin/gdm restore
RUN export BRANCH=`git rev-parse --abbrev-ref HEAD` && \
	export COMMIT=`git rev-parse HEAD` && \
	export LDFLAGS="-X main.version=$VERSION -X main.branch=$BRANCH -X main.commit=$COMMIT" && \
	go install -ldflags "$LDFLAGS" github.com/influxdata/influxdb/cmd/influx && \
	go install -ldflags "$LDFLAGS" github.com/influxdata/influxdb/cmd/influxd && \
	go install -ldflags "$LDFLAGS" github.com/influxdata/influxdb/cmd/influx_inspect && \
	go install -ldflags "$LDFLAGS" github.com/influxdata/influxdb/cmd/influx_stress && \
	go install -ldflags "$LDFLAGS" github.com/influxdata/influxdb/cmd/influx_tsm
RUN ls /go/bin

FROM alpine:3.8
COPY --from=builder /go/bin/influx* /usr/bin/
COPY app.sh /app.sh
CMD ["sh", "/app.sh"]
