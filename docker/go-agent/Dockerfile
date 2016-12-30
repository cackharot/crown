FROM gocd/gocd-agent:latest

MAINTAINER cackharot <cackharot@gmail.com>

RUN apt-get update -y

RUN apt-get install -y python3 python3-pip curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" apt-transport-https ca-certificates linux-image-extra-$(uname -r) linux-image-extra-virtual

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

RUN mv kubectl /bin/kubectl && chmod +x /bin/kubectl

RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

RUN echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list

RUN apt-get update -y

RUN apt-get install -y docker-engine

RUN mkdir -p /etc/docker/certs.d/registry.walkure.net:5000/

RUN mkdir -p /var/go/.kube/

COPY ./kubeconfig.yml /var/go/.kube/config

VOLUME ["/etc/docker/certs.d/","/var/go/.kube/"]

RUN service docker start

RUN apt-get clean

RUN usermod -aG docker go

COPY ./add-extra-hosts.sh /var/go/add-extra-hosts.sh

RUN chmod +x /var/go/add-extra-hosts.sh
