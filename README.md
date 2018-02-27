Apache HBase
------------

Run a standalone node in a Docker container

```
deployabe/hbase:latest
deployabe/hbase:8-1.4.1
deployabe/hbase:8-1.3.1
```

`/data` is mounted as a named volume

Date is stored in `/data/hbase` and `/data/zookeeper`

Build

    ./make.sh build

Run 

    ./make.sh run

