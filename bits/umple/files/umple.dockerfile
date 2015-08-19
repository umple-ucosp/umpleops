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

# Install PHP
ENV PHP_INI_DIR /opt/php
ENV PHP_VERSION @PHP_VERSION@
ENV GPG_KEYS 0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3
RUN apt-get update && \
    apt-get install -y ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2 --no-install-recommends && \
    apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && \
    rm -r /var/lib/apt/lists/* && \
    mkdir -p $PHP_INI_DIR/conf.d && \
    set -xe && \
    for key in $GPG_KEYS; do \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done && \
    buildDeps=" \
        $PHP_EXTRA_BUILD_DEPS \
        libcurl4-openssl-dev \
        libpcre3-dev \
        libreadline6-dev \
        librecode-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
      " && \
      set -x && \
      apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* && \
      curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror" -o php.tar.xz && \
      curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz.asc/from/this/mirror" -o php.tar.xz.asc && \
      gpg --verify php.tar.xz.asc && \
      mkdir -p /usr/src/php && \
      tar -xof php.tar.xz -C /usr/src/php --strip-components=1 && \
      rm php.tar.xz* && \
      cd /usr/src/php && \
      ./configure \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_EXTRA_CONFIGURE_ARGS \
        --disable-cgi \
        --enable-mysqlnd \
        --with-curl \
        --with-openssl \
        --with-pcre \
        --with-readline \
        --with-recode \
        --with-zlib && \
      make -j"$(nproc)" && \
      make install && \
      { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } && \
      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps && \
      make clean

# Install ANT
ENV ANT_HOME /opt/apache-ant-1.8.1
ENV PATH $ANT_HOME/bin:$PATH
ADD src/apache-ant-1.8.1-bin.tar.gz /opt/
ADD src/ant-contrib-1.0b3-bin.tar.gz /opt/
RUN \
  cp /opt/ant-contrib/ant-contrib-1.0b3.jar /opt/apache-ant-1.8.1/lib/ && \
  rm -rf /opt/ant-contrib

# Install UMPLE
ADD bin /usr/local/dockerbin
ENV PATH /usr/local/dockerbin:$PATH
ADD src/qa_index.php /opt/src/qa_index.php
ADD src/cdn_index.php /opt/src/cdn_index.php

VOLUME ["/log", "/src"]
WORKDIR /src/umple