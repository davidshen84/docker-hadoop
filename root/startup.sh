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
      bin/hdfs namenode -format -force
      shift ;;
    --) shift
        break ;;
    *) echo "ERROR!!!"
       exit 1 ;;
  esac
done

startup() {
  sbin/start-dfs.sh
  sbin/start-yarn.sh
  sbin/mr-jobhistory-daemon.sh --config $HADOOP_PREFIX/etc/hadoop start historyserver
}

LOGPID=
teardown() {
  echo "Teardown container!!!"

  sbin/mr-jobhistory-daemon.sh --config $HADOOP_PREFIX/etc/hadoop stop historyserver
  sbin/stop-yarn.sh
  sbin/stop-dfs.sh

  kill -SIGTERM $LOGPID
  exit 0
}

startup
trap "teardown" SIGTERM exit

mkdir -p /opt/hadoop/logs/
touch /opt/hadoop/logs/test.log
tail -f /opt/hadoop/logs/*.log &
LOGPID="$!"
wait $LOGPID
