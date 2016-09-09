#!/bin/sh

OPTS=`getopt -o F --long format-namenode -n "$0" -- "$@"`
eval set -- "$OPTS"

service ssh start
ssh-keyscan localhost,0.0.0.0,`hostname` > ~/.ssh/known_hosts

while true; do
  case "$1" in
    -F|--format-namenode)
      bin/hdfs namenode -format
      shift
      ;;
    --) shift
        break
        ;;
    *) echo "ERROR!!!"
       exit 1
       ;;
  esac
done


sbin/start-dfs.sh
sbin/start-yarn.sh

tail -f /opt/hadoop-2.7.3/logs/*.log

