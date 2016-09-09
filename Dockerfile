FROM openjdk:8-jre
MAINTAINER Xi Shen <davidshen84@gmail.com>

LABEL hadoop=2.7.3 jre=openjdk:8

ENV HADOOP_PREFIX "/opt/hadoop-2.7.3/"

RUN apt-get update && apt-get install -y \
    ssh
RUN service ssh start && \
    ssh-keygen -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
ADD hadoop-2.7.3.tar.gz /opt/

COPY opt/ /opt/
COPY startup.sh /root/
RUN mkdir -p /opt/hadoop-root

EXPOSE \
       # dfs.datanode.address
       50010 \
       # dfs.datanode.ipc.address
       50020 \
       # dfs.namenode.http-address
       50070 \
       # dfs.datanode.http.address
       50075 \
       # yarn.nodemanager.webapp.address
       8042 \
       # yarn.resourcemanager.webapp.address
       8088 \
       # fs.defaultFS
       9000
VOLUME ["/opt/hadoop-2.7.3"]
WORKDIR /opt/hadoop-2.7.3/

ENTRYPOINT ["/root/startup.sh"]
