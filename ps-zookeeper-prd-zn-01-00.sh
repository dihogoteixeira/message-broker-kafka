#!/bin/bash
yum update -y && yum install curl -y && yum install java-1.8.0-openjdk -y
sed -i 's/SELINUX=enforcing/SELINUX=disabled /g' /etc/selinux/config && systemctl disable firewalld && systemctl stop firewalld

# Baixando a instalaçao especifica do zookeeper
cd /opt && { curl -O http://ftp.unicamp.br/pub/apache/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz ; cd -; }

# Alterando o nome da pasta descompactada 
cd /opt && tar -xf apache-zookeeper-3.5.6-bin.tar.gz
mv /opt/apache-zookeeper-3.5.6-bin /opt/zookeeper

# Copiando o arquivo demonstração de configuração para o padrão
cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

# Alterando o diretorio padrão dos logs
sed -i 's/dataDir=\/tmp\/zookeeper/dataDir=\/opt\/zookeeper\/data/g' /opt/zookeeper/conf/zoo.cfg

# Iniciando primeiro serviço do zookeeper por default ja é iniciado em background
# /opt/zookeeper/bin/zkServer.sh start &

cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=Zookeeper
Wants=syslog.target

[Service]
Type=forking
User=root
ExecStart=/bin/sh -c '/opt/zookeeper/bin/zkServer.sh start'
TimeoutSec=30
Restart=on-failure

Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

# Iniciando o serviço do zookeeper
systemctl start zookeeper.service
systemctl enable zookeeper.service

exit 0