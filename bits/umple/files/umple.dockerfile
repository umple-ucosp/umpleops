FROM ubuntu:14.04

MAINTAINER Andrew Forward (aforward@gmail.com)

# Install JAVA
ENV JAVA_VERSION @JAVA_VERSION@
ENV JAVA_FILENAME @JAVA_FILENAME@
ENV JAVA_URL @JAVA_BASEURL@/$JAVA_FILENAME
ENV JAVA_HOME /opt/src/java/jdk$JAVA_VERSION
ENV PATH $JAVA_HOME/bin:$PATH
RUN \
  apt-get update && \
  apt-get install -y wget && \
  apt-get clean && \
  wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_URL -O /tmp/$JAVA_FILENAME && \
  mkdir -p /opt/src/java && \
  tar -zxf /tmp/$JAVA_FILENAME -C /opt/src/java/ && \
  rm -f /tmp/$JAVA_FILENAME && \
  update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && \
  update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# Install ANT
ENV ANT_HOME=/opt/apache-ant-1.8.1
ENV PATH $ANT_HOME/bin:$PATH
ADD src/apache-ant-1.8.1-bin.tar.gz /opt/
ADD src/ant-contrib-1.0b3-bin.tar.gz /opt/
RUN \
  cp /opt/ant-contrib/ant-contrib-1.0b3.jar /opt/apache-ant-1.8.1/lib/ && \
  rm -rf /opt/ant-contrib

# Install UMPLE
ADD bin /usr/local/dockerbin
ENV PATH /usr/local/dockerbin:$PATH

VOLUME ["/log", "/src"]
WORKDIR /src/umple