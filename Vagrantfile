# -- mode: ruby --
# vi: set ft=ruby :
require 'yaml'
yaml = YAML.load_file("machines.yml")
Vagrant.configure("2") do |config|
  yaml.each do |server|
    config.vm.define server["name"] do |srv|
      srv.vm.box = server["sistema"]
      srv.vm.network "private_network", ip: server["ip"]
      srv.vm.hostname = server["hostname"]
      srv.vm.provider "virtualbox" do |vb|
        vb.name = server["name"]
        vb.memory = server["memory"]
        vb.cpus = server["cpus"]
      end
  end

     config.vm.provision "shell", inline: <<-SHELL
     if [ $HOSTNAME = "ps-zookeeper-prd-zn-01-00" ]; then
       cp /vagrant/ps-zookeeper-prd-zn-01-00.sh /opt/ps-zookeeper-prd-zn-01-00.sh
       cd /opt && bash ./ps-zookeeper-prd-zn-01-00.sh
     fi;
     if [ $HOSTNAME = "ps-kafka-prd-zn-01-00" ]; then
     echo $HOSTNAME
     cp /vagrant/ps-kafka-prd-zn-01-00.sh /opt/ps-kafka-prd-zn-01-00.sh
     cd /opt && bash ./ps-kafka-prd-zn-01-00.sh
     fi;

     if [ $HOSTNAME = "ps-kafka-prd-zn-02-01" ]; then
     echo $HOSTNAME
     cp /vagrant/ps-kafka-prd-zn-02-01.sh /opt/ps-kafka-prd-zn-02-01.sh
     cd /opt && bash ./ps-kafka-prd-zn-02-01.sh
     fi;

     if [ $HOSTNAME = "ps-kafka-prd-zn-03-02" ]; then
     echo $HOSTNAME
     cp /vagrant/ps-kafka-prd-zn-03-02.sh /opt/ps-kafka-prd-zn-03-02.sh
     cd /opt && bash ./ps-kafka-prd-zn-03-02.sh
     fi;
      SHELL
  end
end

