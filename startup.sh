#!/bin/sh

OPTS=`getopt -o fu: --long format-namenode,create-user: -n "$0" -- "$@"`
eval set -- "$OPTS"

service ssh start
# initialize the known hosts dynamically
ssh-keyscan localhost,0.0.0.0,`hostname` >> ~/.ssh/known_hosts

while true; do
  case "$1" in
    -f|--format-namenode)
      bin/hdfs namenode -format
      shift
      ;;
    -u|--create-user)
      useradd -MU "$2"
      shift 2
      ;;
    --) shift
        break
        ;;
    *) echo "ERROR!!!"
       exit 1
       ;;
  esac
done

# Allow HDFS service to be access with its external name
sed -e "s/HOSTNAME/`hostname`/" -i /opt/hadoop-2.7.3/etc/hadoop/core-site.xml
sbin/start-dfs.sh
sbin/start-yarn.sh
sbin/mr-jobhistory-daemon.sh --config $HADOOP_PREFIX/etc/hadoop start historyserver

tail -f /opt/hadoop-2.7.3/logs/*.log

