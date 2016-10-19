#!/bin/bash

set -m

OPTS=`getopt -o h --long help,format-namenode -n "$0" -- "$@"`
eval set -- "$OPTS"

service ssh start
# initialize the known hosts dynamically
ssh-keyscan localhost,0.0.0.0,`hostname` >> ~/.ssh/known_hosts

while true; do
  case "$1" in
    -h|--help)
      echo "HELP"
      shift ;;
    -f|--format-namenode)
      [ -d /data/dfs ] && rm -rf /data/dfs
      bin/hdfs namenode -format -force
      shift ;;
    --) shift
        break ;;
    *) echo "ERROR!!!"
       exit 1 ;;
  esac
done

start() {
  sbin/start-dfs.sh
  sbin/start-yarn.sh
  sbin/mr-jobhistory-daemon.sh --config $HADOOP_PREFIX/etc/hadoop start historyserver

  # it takes a long time for the components to startup in a pseudo-cluster
  sleep 30
}

LOG_PID=
stop() {
  echo "Teardown container!!!"

  sbin/mr-jobhistory-daemon.sh --config $HADOOP_PREFIX/etc/hadoop stop historyserver
  sbin/stop-yarn.sh
  sbin/stop-dfs.sh

  kill -SIGTERM $LOG_PID
  exit 0
}

start
trap "stop" SIGTERM exit

tail -f /opt/hadoop/logs/*.log &
LOG_PID="$!"
wait $LOG_PID
