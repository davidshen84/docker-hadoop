FROM openjdk:8-jre
MAINTAINER Xi Shen <davidshen84@gmail.com>

LABEL hadoop=2.7.3 jre=openjdk:8

RUN apt-get update && apt-get install -y \
    ssh

COPY etc /
ADD hadoop-2.7.3.tar.gz /opt/
COPY opt/ /opt/hadoop-2.7.3
RUN mkdir -p /opt/hdfs

#EXPOSE ..
WORKDIR /opt/hadoop-2.7.3/

