#!/bin/bash

your_ip=$1
PORT = 9100

###.1.PROMETHEUS.####

sudo yum update

cd /var/tmp/

wget https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz
filename="$(find /var/tmp/ -name "*.gz")"

tar xvfz $filename

# tar xvfz prometheus-*.tar.gz
rm -f $filename

filename=$(echo "$filename" | cut -f 1 -d '-')
echo "$filename"
sudo mv $filename* /etc/prometheus

cd /etc/systemd/system
sudo touch prometheus.service
sudo chmod ugo+rwx /etc/systemd/system/prometheus.service

cd /vagrant
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
ExecStart=/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml
Restart=always
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl restart prometheus
sudo systemctl enable prometheus

###.2.PROMETHEUS - node exporter.####

cd /var/tmp/

wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
filename="$(find /var/tmp/ -name "*.gz")"

tar xvfz $filename

# tar xvfz prometheus-*.tar.gz
rm -f $filename

filename=$(echo "$filename" | cut -f 1 -d '-')
echo "$filename"
sudo mv $filename* /etc/node_exporter

cd /etc/systemd/system
sudo touch node_exporter.service
sudo chmod ugo+rwx /etc/systemd/system/node_exporter.service

cd /vagrant
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
ExecStart=/etc/node_exporter/node_exporter
Restart=always
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl restart node_exporter
sudo systemctl enable node_exporter

rm -rf /etc/prometheus/prometheus.yml
touch /etc/prometheus/prometheus.yml
sudo chmod ugo+rwx /etc/prometheus/prometheus.yml
echo "global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['192.168.56.22:9100']" > /etc/prometheus/prometheus.yml

###.3.GRAFANA.####

sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-10.3.1-1.x86_64.rpm

sudo systemctl restart grafana-server
sudo systemctl enable grafana-server



