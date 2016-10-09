FROM openjdk:8-jre
MAINTAINER Xi Shen <davidshen84@gmail.com>

LABEL hadoop=2.7.3 jre=openjdk:8

RUN apt-get update && apt-get install -y \
    ssh
ONBUILD COPY .ssh /root/.ssh

ADD http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz /opt/
RUN mkdir /opt/hadoop && \
    tar xzf /opt/hadoop-2.7.3.tar.gz --strip-components=1 -C /opt/hadoop && \
    rm /opt/hadoop-2.7.3.tar.gz

COPY opt/ /opt/
COPY startup.sh /root/

EXPOSE \
       # dfs.datanode.address
       50010 \
       # dfs.datanode.ipc.address
       50020 \
       # dfs.namenode.http-address
       50070 \
       # dfs.datanode.http.address
       50075 \
       # yarn.app.mapreduce.am.job.client.port-range
       50100-50200 \
       # yarn.resourcemanager.address
       8032 \
       # yarn.nodemanager.webapp.address
       8042 \
       # yarn.resourcemanager.webapp.address
       8088 \
       # fs.defaultFS
       9000 \
       # mapreduce.jobhistory.webapp.address
       19888

ENV HADOOP_PREFIX=/opt/hadoop
VOLUME ["/data"]
WORKDIR /opt/hadoop

ENTRYPOINT ["/root/startup.sh"]
