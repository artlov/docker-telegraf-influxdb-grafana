# Docker Image with Telegraf, InfluxDB and Grafana
This is a Docker image based on the [Docker Image with Telegraf (StatsD), InfluxDB and Grafana](https://github.com/samuelebistoletti/docker-statsd-influxdb-grafana) from [Samuele Bistoletti](https://github.com/samuelebistoletti) and [Docker Image with InfluxDB and Grafana](https://github.com/philhawthorne/docker-influxdb-grafana) from [Phil Hawthorne](https://github.com/philhawthorne). The main purpose of this image is to be used to show data from a Domoticz installation and Synology NAS, which hosted this image.

The main points of this image are:

* Persistence is supported via mounting volumes to a Docker container.
* Grafana will store its data in SQLite files instead of a MySQL table on the container, so MySQL is not installed.
* Added snmp packages and Synology NAS MIBS.

## Versions

* Ubuntu:            18.04
* InfluxDB:          1.7.6
* Chronograf:        1.7.11
* Telegraf:          1.10.4-1
* Grafana:           6.2.1

## Quick Start

To start the container the first time launch:

```sh
docker run --ulimit nofile=66000:66000 -d \
  --name docker-telegraf-influxdb-grafana \
  -p 3003:3003 \
  -p 3004:8888 \
  -p 8086:8086 \
  -p 22022:22 \
  -p 8125:8125/udp \
  -v /path/for/influxdb:/var/lib/influxdb \
  -v /path/for/grafana:/var/lib/grafana \
  artlov/docker-telegraf-influxdb-grafana:latest
```

You can replace `latest` with the desired version listed in changelog file.

To stop the container launch:

```sh
docker stop docker-telegraf-influxdb-grafana
```

To start the container again launch:

```sh
docker start docker-telegraf-influxdb-grafana
```

## Mapped Ports

```
Host		Container	Service

3003		3003		grafana
3004		8888		influxdb-admin (chronograf)
8086		8086		influxdb
8125		8125		telegraf
22022		22		sshd
```
## SSH

```sh
ssh root@localhost -p 22022
```
By default root password login disabled. If ssh connection needed, please configure key authentication.

Access from docker host:
```
docker exec -it <container id> bash
```

## Grafana

Open <http://localhost:3003>

```
Username: root
Password: root
```

### Add data source on Grafana

1. Using the wizard click on `Add data source`
2. Choose a `name` for the source and flag it as `Default`
3. Choose `InfluxDB` as `type`
4. Choose `direct` as `access`
5. Fill remaining fields as follows and click on `Add` without altering other fields

```
Url: http://localhost:8086
Database:	telegraf
User:		telegraf
Password:	telegraf
```

Basic auth and credentials must be left unflagged. Proxy is not required.

Now you are ready to add your first dashboard and launch some query on database.

## InfluxDB

### Web Interface

Open <http://localhost:3004>

```
Username: root
Password: root
Port: 8086
```

### InfluxDB Shell (CLI)

1. Establish a ssh connection with the container
2. Launch `influx` to open InfluxDB Shell (CLI)
