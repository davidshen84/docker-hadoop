#!/bin/sh

OPTS=`getopt -o F --long format-namenode -n "$0" -- "$@"`
eval set -- "$OPTS"

format_namenode=""

while true; do
  case "$1" in
    -F|--format-namenode)
      format_namenode="$1"
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

service ssh start
ssh-keyscan localhost,0.0.0.0,`hostname` > ~/.ssh/known_hosts
[ -n "$format_namenode" ] && bin/hdfs namenode -format
sbin/start-dfs.sh
sbin/start-yarn.sh

tail -f /opt/hadoop-2.7.3/logs/*.log

