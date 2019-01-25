FROM registry.cn-beijing.aliyuncs.com/kubebase/golang-builder:latest as builder
RUN mkdir -p $GOPATH/src/github.com/influxdata
WORKDIR $GOPATH/src/github.com/influxdata
RUN git clone -b v1.2 --depth=1 https://github.com/ops-itop/kapacitor
WORKDIR kapacitor
RUN export BRANCH=`git rev-parse --abbrev-ref HEAD` && \
    export COMMIT=`git rev-parse HEAD` && \
	export LDFLAGS="-X main.version=v1.2 -X main.branch=$BRANCH -X main.commit=$COMMIT" && \
	go install -ldflags="$LDFLAGS" github.com/influxdata/kapacitor/cmd/kapacitor && \
	go install -ldflags="$LDFLAGS" github.com/influxdata/kapacitor/cmd/kapacitord
RUN ls /go/bin

FROM alpine:3.8
COPY --from=builder /go/bin/ /usr/bin/
COPY app.sh /app.sh
CMD ["sh", "/app.sh"]
