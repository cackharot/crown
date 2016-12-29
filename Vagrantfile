# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = true
  config.vm.synced_folder "~/projects", "/projects"

  #config.vm.network "forwarded_port", guest: 5601, host: 9000 #kibana
  #config.vm.network "forwarded_port", guest: 9200, host: 9200 #elasticsearch
  #config.vm.network "forwarded_port", guest: 5000, host: 5000 #logstash
  #config.vm.network "forwarded_port", guest: 8080, host: 9080 #anpp?

  config.vm.define :chaos, primary: true do |chaos|
    chaos.vm.box = "ubuntu/trusty64"
    chaos.vm.network "private_network", ip: "172.16.0.253"

    chaos.vm.provision "ansible" do |ab|
      ab.playbook = "ansible/crown_server.yml"
    end

    chaos.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "4096"
    end
  end

  (1..2).each do |i|
    config.vm.define "drone-#{i}" do |drone|
      drone.vm.box = "ubuntu/trusty64"
      drone.vm.network "private_network", ip: "172.16.0.#{10+i}"
      drone.vm.provision "shell", inline: "echo hello from drone #{i}"
      drone.vm.provision "ansible" do |ab|
        ab.playbook = "ansible/drone_minion.yml"
      end

      drone.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
      end
    end
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "private_network", ip: "192.168.33.10"

  #config.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)"
end
