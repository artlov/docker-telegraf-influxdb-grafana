FROM ubuntu:18.04
MAINTAINER Arthur Kono <artlov@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV TELEGRAF_VERSION 1.9.2-1
ENV INFLUXDB_VERSION 1.7.2
ENV GRAFANA_VERSION  5.3.2
ENV CHRONOGRAF_VERSION 1.7.5

# Database Defaults
ENV INFLUXDB_GRAFANA_DB datasource
ENV INFLUXDB_GRAFANA_USER datasource
ENV INFLUXDB_GRAFANA_PW datasource

ENV GF_DATABASE_TYPE=sqlite3

#ENV MYSQL_GRAFANA_USER grafana
#ENV MYSQL_GRAFANA_PW grafana

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

# Base dependencies

# apt-get -y --force-yes install \

RUN apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y install \
  apt-utils \
  ca-certificates \
  curl \
  git \
  htop \
  libfontconfig \
  nano \
  net-tools \
  openssh-server \
  supervisor \
  gnupg \
  gnupg2 \
  gnupg1 \
  snmp \
  snmp-mibs-downloader \
  wget && \
 curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
 apt-get install -y nodejs

# Configure Supervisord, SSH and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root

RUN mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd && \
    rm -rf .ssh && \
    rm -rf .profile && \
    mkdir .ssh

COPY ssh/id_rsa .ssh/id_rsa
COPY bash/profile .profile

# Configure MySql
#COPY scripts/setup_mysql.sh /tmp/setup_mysql.sh

#RUN /tmp/setup_mysql.sh

# Install InfluxDB
RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
	dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && rm influxdb_${INFLUXDB_VERSION}_amd64.deb

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf
COPY influxdb/init.sh /etc/init.d/influxdb

# Install Telegraf
RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}_amd64.deb && \
	dpkg -i telegraf_${TELEGRAF_VERSION}_amd64.deb && rm telegraf_${TELEGRAF_VERSION}_amd64.deb

# Configure Telegraf
COPY telegraf/telegraf.conf /etc/telegraf/telegraf.conf
COPY telegraf/init.sh /etc/init.d/telegraf

# Install chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_amd64.deb && \
  dpkg -i chronograf_${CHRONOGRAF_VERSION}_amd64.deb

# Install Grafana
RUN wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
	dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Configure Grafana with provisioning
ADD grafana/provisioning /etc/grafana/provisioning
ADD grafana/dashboards /var/lib/grafana/dashboards
COPY grafana/grafana.ini /etc/grafana/grafana.ini

VOLUME /var/lib/influxdb
VOLUME /var/lib/grafana

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/supervisord"]
