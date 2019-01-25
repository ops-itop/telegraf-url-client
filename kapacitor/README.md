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
