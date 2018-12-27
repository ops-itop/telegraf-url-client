# telegraf url_monitor client

## 新版容器化
使用kubernetes部署，目前只能部署一个节点

### 需要以下环境变量
```
GIT_REPO  url monitor配置文件git仓库
NODE      监控节点名称(China, HongKong, UnitedStates)
TELEGRAF_CONFIG  telegraf配置文件
```

## legacy
初始化一个监控节点，git pull本节点监控项，如有变更，则reload telegraf

### 扩容

暂时没有实现。想法如下：

角色分为：任务调度，任务执行。

调度机git pull本节点监控项，然后平均分配到各执行节点。

执行节点删除旧配置，使用新配置reload telegraf

grafana 添加展示时，仅使用monitor_node做节点标识，不关心具体在哪个hostname上执行
