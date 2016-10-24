# docker-oozie

Pull

    docker pull pluk/oozie

Uploading sharelib into hdfs

    docker run --rm pluk/oozie oozie-setup.sh sharelib create -fs hdfs://namenode:port

Start Oozie with mounting all configuration files

    docker run -d --name oozie \ 
        -p 11000:11000 \
        -p 11001:11001 \
        -v core-site.xml:/usr/local/oozie/conf/hadoop-conf/core-site.xml \
        -v mapred-site.xml:/usr/local/oozie/conf/hadoop-conf/mapred-site.xml \
        -v yarn-site.xml:/usr/local/oozie/conf/hadoop-conf/yarn-site.xml \
        -v hdfs-site.xml:/usr/local/oozie/conf/hadoop-conf/hdfs-site.xml \
        -v oozie-site.xml:/usr/local/oozie/conf/oozie-site.xml \
        -v /var/log/oozie:/usr/local/oozie/logs \
        pluk/oozie
