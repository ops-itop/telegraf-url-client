IMAGENAME ?= telegraf-url
REGISTRY ?= registry.cn-beijing.aliyuncs.com/kubebase
TAG ?= latest
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
	docker build $(PROXY) -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

# 本地调试
debug: build-docker run

# 本地运行容器，需要先判断容器是否存在
run:
ifeq ($(exists), yes)
	docker stop $(APP);docker rm $(APP)
endif
	docker run --name $(APP) -d --env APP_CONFIG_PATH=$(APP_CONFIG_PATH) -v $(PWD)/url.conf:$(APP_CONFIG_PATH)/TELEGRAF_CONFIG $(IMAGE):$(TAG)
