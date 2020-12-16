FROM ubuntu:20.04

LABEL maintainer="Arthur Kono <artlov@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
#ENV TZ=Europe/Tallinn

# Default versions
ENV TELEGRAF_VERSION 1.16.3-1
ENV INFLUXDB_VERSION 1.8.3
ENV GRAFANA_VERSION  7.3.5
ENV CHRONOGRAF_VERSION 1.8.9.1

ENV GF_DATABASE_TYPE=sqlite3

# Fix bad proxy issue
#COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

# Base dependencies

RUN apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y install \
  apt-utils \
  ca-certificates \
  curl \
  git \
  htop \
  libfontconfig \
  mc \
  net-tools \
  openssh-server \
  supervisor \
  gnupg \
  gnupg2 \
  gnupg1 \
  snmp \
  snmp-mibs-downloader \
  wget && \
 curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
 apt-get install -y nodejs

# Configure Supervisord, SSH and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /root

RUN mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    rm -rf .ssh && \
    rm -rf .profile && \
    mkdir .ssh

COPY ssh/id_rsa .ssh/id_rsa
COPY bash/profile .profile

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
RUN mv -f /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.default 
COPY telegraf/telegraf.conf /etc/telegraf/telegraf.conf
COPY telegraf/init.sh /etc/init.d/telegraf

# Install Chronograf
RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_amd64.deb && \
 dpkg -i chronograf_${CHRONOGRAF_VERSION}_amd64.deb  && rm chronograf_${CHRONOGRAF_VERSION}_amd64.deb

# Install Grafana
RUN wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb && \
 dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb && rm grafana_${GRAFANA_VERSION}_amd64.deb

# Configure Grafana with provisioning
ADD grafana/provisioning /etc/grafana/provisioning
COPY grafana/grafana.ini /etc/grafana/grafana.ini

# Synology SNMP
COPY synology/synology.conf /etc/telegraf/telegraf.d
COPY synology/Synology_MIB_File.tar.gz /tmp
RUN tar -xvzf /tmp/Synology_MIB_File.tar.gz -C /usr/share/snmp/mibs
RUN chown root:root /usr/share/snmp/mibs
RUN chmod 755 /usr/share/snmp/mibs

# Install plugins
#COPY rootfs /tmp
#RUN /tmp/grafana-plugins.sh

EXPOSE 22/tcp 3003/tcp 8086/tcp 8888/tcp 8125/udp
#VOLUME /var/lib/influxdb /var/lib/grafana /var/lib/backups

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/bin/supervisord"]
