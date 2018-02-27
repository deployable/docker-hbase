#!/bin/sh

set -uex

cmd=${1:-hbase}
shift

hbase(){
  #exec /usr/local/bin/gosu 20030:20030 /hbase/bin/hbase-daemon.sh foreground_start
  /hbase/bin/hbase \
    --config /hbase/conf \
    master "$@" start
}

zookeeper(){
  exec /usr/local/bin/gosu 20029:20029 /kafka/bin/zookeeper-server-start.sh /kafka/config/zookeeper.properties
}

setup(){
  sleep 1
  if [ -n "$KAFKA_TOPIC" ]; then 
    echo "setting up [$KAFKA_TOPIC]"
    /usr/local/bin/gosu 20029:20029 /kafka/bin/kafka-topics.sh \
      --create \
      --zookeeper zookeeper:2181 \
      --replication-factor 1 \
      --partitions 1 \
      --topic "$KAFKA_TOPIC"
  fi
}

$cmd "$@"
exit $?
