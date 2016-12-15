# crown


## Requirements

* Vagrant
* Virtualbox
* Ansible

# Setup the cluster

* vagrant up --provision
* sh setup_chaos.sh
* sudo docker run -d -p 5000:5000 --restart=always --name registry registry:latest


# Running GoCD

* cd docker/go-server
* sudo docker build -t frigate .
* sudo docker tag frigate localhost:5000/frigate
* sudo docker push localhost:5000/frigate

* kubctl create -f deployments/ops/ci/gocd.yml --record
* kubectl expose deployment gocd-server-deployment --type=NodePort --name=gocd-server-service

Open http://172.16.0.253:32334/
