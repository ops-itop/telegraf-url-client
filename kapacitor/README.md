# Kapacitor

## 注意事项

### hostname

hostname 需要是可以解析的域名

```
# show subscriptions
telegraf
retention_policy	name	mode	destinations
autogen	"kapacitor-c6586b14-8ef0-4ff4-b8a5-ba6023dbc725"	"ANY"	udp://kapacitor:40011
default	"kapacitor-c6586b14-8ef0-4ff4-b8a5-ba6023dbc725"	"ANY"	udp://kapacitor:49668
```

### retention_policy

1.0之后的版本似乎没有默认的`default` rp了，如果未指定rp，会是 `autogen`。需要注意在`telegraf`配置文件中指定`rp`

telegraf， kapacitor的`rp`需要一致

retention policy 为 `autogen`时，无法触发报警，可能是因为`autogen`的`duration`为 `0s`

```

name	duration	shardGroupDuration	replicaN	default
autogen	"0s"	"168h0m0s"	1	true
default	"168h0m0s"	"24h0m0s"	1	false
```

创建`default` retention_policy
```
show RETENTION POLICIES ON telegraf
create RETENTION POLICY "default" ON telegraf DURATION 7d REPLICATION 1
```
