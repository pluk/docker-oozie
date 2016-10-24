FROM delitescere/jdk
MAINTAINER Andrey Tretyakov <andrey.tretyakov.a@gmail.com>

ENV HADOOP_VERSION  2.6.0
ENV HADOOP_HOME     /usr/local/hadoop

ENV OOZIE_VERSION   4.2.0
ENV OOZIE_HOME      /usr/local/oozie

ENV MAVEN_VERSION   3.3.9

ENV PATH            $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$OOZIE_HOME/bin

RUN addgroup hadoop && adduser -G hadoop -D -H hadoop && \
    addgroup oozie && adduser -G oozie -D -H oozie

RUN apk add --update curl bash zip && \
    mkdir -m 777 /tmp && \
    curl -kL http://www-eu.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar -zx -C /tmp && \
    mv /tmp/hadoop-$HADOOP_VERSION /usr/local/hadoop && chown -R hadoop:hadoop /usr/local/hadoop && \
# Download Maven
    curl -kL http://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -zx -C /tmp && \
# Download Oozie
    curl -kL http://www-eu.apache.org/dist/oozie/$OOZIE_VERSION/oozie-$OOZIE_VERSION.tar.gz | tar -zx -C /tmp && \
# Build Oozie
    cd /tmp/oozie-$OOZIE_VERSION && \
    /tmp/apache-maven-$MAVEN_VERSION/bin/mvn clean package assembly:single -DskipTests -P hadoop-2,uber -Dhadoop.version=2.6.0 && \
    tar -xzf /tmp/oozie-$OOZIE_VERSION/distro/target/oozie-$OOZIE_VERSION-distro.tar.gz -C /usr/local && \
    mv /usr/local/oozie-$OOZIE_VERSION $OOZIE_HOME && \
    mkdir $OOZIE_HOME/libext && \
    wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip -P $OOZIE_HOME/libext/ && \
    curl -kL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz | tar -xz -C /tmp && \
    mv /tmp/mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar $OOZIE_HOME/libext && \
    chown -R oozie:oozie $OOZIE_HOME && \
    rm -rf /root/.m2 && \
    apk del curl && rm -rf /tmp/* /var/cache/apk/*

EXPOSE 11000 11001

USER oozie

RUN $OOZIE_HOME/bin/oozie-setup.sh prepare-war
WORKDIR $OOZIE_HOME

ENTRYPOINT ["/bin/bash"]
