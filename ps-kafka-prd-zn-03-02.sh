#!/bin/bash
yum update -y && yum install curl -y && yum install java-1.8.0-openjdk -y
sed -i 's/SELINUX=enforcing/SELINUX=disabled /g' /etc/selinux/config && systemctl disable firewalld && systemctl stop firewalld

# Baixando a instalação especifica do kafka
cd /opt && { curl -O http://ftp.unicamp.br/pub/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz ; cd -; }

# Alterando o nome da pasta descompactada
cd /opt && tar -xf kafka_2.12-2.3.0.tgz
sudo mv /opt/kafka_2.12-2.3.0 /opt/kafka
sudo mkdir /opt/kafka/logs/

# Alterando o caminho do zookeeper para comunicação
sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect=192.168.66.30:2181/g' /opt/kafka/config/server.properties
sed -i "s/broker.id=0/broker.id=2/g" /opt/kafka/config/server.properties

# Criando daemon do kafka
cat <<EOF > /etc/systemd/system/kafka.service 
[Unit]
#Requires=zookeeper.service
#After=zookeeper.service

[Service]
Type=simple
User=root
ExecStart=/bin/sh -c '/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties >> /opt/kafka/logs/kafka.log 2>&1'
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

# Iniciando serviço do kafka
systemctl start kafka.service
systemctl enable kafka.service

if [ 0 -eq $BROKER_ID ]
then
	# Para a primeira execução, criar os topicos que utilizamos na PS
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_e_rede
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_process_order
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_error
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_wait_antifraude
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_antifraude
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_cielo
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_sms
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_email
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_gateway_payment
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic billet_process
	/opt/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.66.30:2181 --replication-factor 2 --partitions 4 --topic topic_process_billet
fi

exit 0