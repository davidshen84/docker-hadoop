# README
## Build the image
This image has **ONBUILD** statement, you should build your own image
based on it.

The **ONBUILD** statements will copy the contents in the `.ssh`
directory, relative to *current* location, to `/root/.ssh` in the
image. You can use your own SSH RSA keys, or generate with the
following snippet.

```sh
mkdir .ssh
ssh-keygen -P '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub > .ssh/authorized_keys
```

## Create the container
```sh
docker run -d \
  -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 \
  -p 50100-50200:50100-50200 \
  -p 8032:8032 -p 8042:8042 -p 8088:8088 -p 9000:9000 -p 19888:19888 \
  --volume /your/hadoop/root:/data \
  --name hadoop --hostname hadoop \
  hadoop --format-namenode
```

If you map `/data` to your docker host, the changes you made to
this Hadoop instance can be persisted. `--format-namenode` will do
`hdfs namenode -format`. If you want persistent storage, you should
not specify it when you run the container a 2nd time.

## Change /user directory permission
```sh
hdfs dfs -chmod 1773 /user
hdfs dfs -chmod 1773 /user/history
```

## Configure the client
### core-site.xml
```xml
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://hadoop-host:9000</value>
</property>
```

Replace `hadoop-host` with the real host name returned by your docker.

### hdfs-site.xml
```xml
  <property>
    <name>dfs.client.use.datanode.hostname</name>
    <value>true</value>
  </property>
```

Configure the *hosts* file on your OS, so you can access your hadoop
host using its host name, instead of the IP. This is necessary if your
docker engine is in a virtual machine, *e.g. the Docker Tool Kit on
Windows/Mac*

### yarn-site.xml
```xml
<property>
  <name>yarn.resourcemanager.hostname</name>
  <value>hadoop-host</value>
</property>

<property>
  <name>yarn.nodemanager.remote-app-log-dir</name>
  <value>/user/logs</value>
</property>
```
  
## Verify if the Hadoop instance is working
1. Create a directory for your user.
  ```sh
  hdfs dfs -mkdir /user/hadoop-user
  ```

2. Upload some text file as input
  ```sh
  hdfs dfs -put /path/to/text/ input
  ```
3. Run map/reduce job as a client
  ```sh
  hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar grep input output 'dfs.+'
  ```
4. Get the output
  ```sh
  hdfs dfs -get output output
  ls output
  ```
5. Check the job log from YARN
  ```sh
  yarn logs -applicationId application_id_number
  ```
