# README

## Build the image

This image has **ONBUILD** statement, you should build your own image
based on it.

The **ONBUILD** statements will copy the contents in the `.ssh`
directory, relative to *current* location to `/root/.ssh`. You can use
your own SSH RSA keys, or generate with the following snippet.

```sh
mkdir .ssh
ssh-keygen -P '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub > .ssh/authorized_keys
```


## Create the container

```sh
docker run -d \
  -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 \
  -p 8042:8042 -p 8088:8088 -p 9000:9000 -p 19888:19888 \
  -v /your/hadoop/root:/opt/hadoop \
  --name hadoop \
  hadoop --format-namenode
```

If you map `/opt/hadoop` to your docker host, the changes you made to
this Hadoop instance can be persisted. `--format-namenode` will do
`hdfs namenode -format`. If you want persistent storage, you should
not specify it when you run the container a 2nd time.

## Configure the client

Update your `core-site.xml` as follow:

```xml
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://container_host_name:9000</value>
</property>
```

Replace `container_host_name` with the real host name returned by your
docker.

Update your `hdfs-site.xml` as follow:

```xml
  <property>
    <name>dfs.client.use.datanode.hostname</name>
    <value>true</value>
  </property>
```

Configure the *hosts* file on your OS, so you can access your
container using the container's host name, instead of the IP. This is
necessary if your container is in a virtual machine, *e.g. the Docker
tool kit on Windows/Mac*
