# telegraf url_monitor client

初始化一个监控节点，git pull本节点监控项，如有变更，则reload telegraf

## 扩容

暂时没有实现。想法如下：

角色分为：任务调度，任务执行。

调度机git pull本节点监控项，然后平均分配到各执行节点。

执行节点删除旧配置，使用新配置reload telegraf

grafana 添加展示时，仅使用monitor_node做节点标识，不关心具体在哪个hostname上执行
