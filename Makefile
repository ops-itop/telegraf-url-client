IMAGENAME ?= telegraf-url
REGISTRY ?= registry.cn-beijing.aliyuncs.com/kubebase
TAG ?= $(shell git rev-parse --short HEAD)
IMAGE = $(REGISTRY)/$(IMAGENAME)
PROXY ?= 
APP ?= $(shell pwd |awk -F'/' '{print $$NF}')

# 判断本地是否允许此容器，用于调试
exists ?= $(shell docker ps -a |grep $(APP) &>/dev/null && echo "yes" || echo "no")

PWD =$(shell pwd)

# k8s预定义的APP_CONFIG_PATH环境变量默认值为/run/secret/appconfig
APP_CONFIG_PATH ?= /run/secret/appconfig

all: build-docker push

build-docker:
	docker build $(PROXY) -t $(IMAGE):latest .
	docker build $(PROXY) -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

# 本地调试
debug: build-docker run

# 本地运行容器，需要先判断容器是否存在
run:
	$(shell [ ! -d $(PWD)/debug/datadir ] && mkdir -p $(PWD)/debug/datadir; [ ! -f $(PWD)/debug/url.conf ] && cp $(PWD)/url.conf.sample $(PWD)/debug/url.conf)
ifeq ($(exists), yes)
	docker stop $(APP);docker rm $(APP)
endif
	docker run --name $(APP) -d --env APP_CONFIG_PATH=$(APP_CONFIG_PATH) -v $(PWD)/debug/url.conf:$(APP_CONFIG_PATH)/TELEGRAF_CONFIG -v $(PWD)/debug/datadir:/telegraf-url $(IMAGE):$(TAG)
