# Continuous Integration and Delivery of Microservices

Continuous Integration and Delivery of Microservices-based REST API with RestExpress, Java EE, and MongoDB, using Jenkins CI, Docker Machine, and Docker Compose.

__PROJECT CODE UPDATED: 11-06-2016__  

_NOTE: This project was originally built prior to Docker 1.12.x. Certain conventions used in the Docker Compose v1 YAML file are pre-1.12.x._

### Introduction
In the below series of posts, we learned how to use Jenkins CI, Maven, Docker, Docker Compose, and Docker Machine to take a set of Java-based microservices from source control on GitHub, to a fully tested set of integrated Docker containers running within an Oracle VirtualBox VM. We performed integration tests, using a scripted set of synthetic transactions, to make sure the microservices were functioning as expected, within their containers.

<p><a href="https://programmaticponderings.files.wordpress.com/2015/08/elk-stack-3d-diagram-1.png"><img style="border:0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/08/elk-stack-3d-diagram-1.png?w=620" alt="ELK Stack 3D Diagram"/></a></p>

### Reference Blog Posts
* [Containerized Microservice Log Aggregation and Visualization using ELK Stack and Logspout](http://wp.me/p1RD28-1wl)
* [Continuous Integration and Delivery of Microservices using Jenkins CI, Docker Machine, and Docker Compose](http://wp.me/p1RD28-1uZ)
* [Building a Microservices-based REST API with RestExpress, Java EE, and MongoDB: Part 3](http://wp.me/p1RD28-1sc)

### Build Test Environment Project
```bash
# check for latest versions of required apps
docker -v && docker-compose -v && \
docker-machine -v && VBoxManage --version

# pull this GitHub project
git clone https://github.com/garystafford/virtual-vehicles-docker.git && \
cd virtual-vehicles-docker

# clean up any previous machine failures
docker-machine stop test || echo "nothing to stop" && \
docker-machine rm test   || echo "nothing to remove"

# use docker-machine to create and configure 'test' environment
docker-machine --debug create --driver virtualbox test
eval "$(docker-machine env test)"

# pull build artifacts from virtual-vehicles-demo project
# build (4) Dockerfiles and docker-compose.yml from templates
sh pull_and_build.sh

# use docker-compose to pull and build new images and containers
# this will take up to 20 minutes or more to pull images
docker-compose -p vehicle up -d

# list machines, images, and containers
docker-machine ls && docker images && docker ps -a

# wait for containers to fully start before tests fire up
sleep 30

# add local dns name to hosts file for demo (mac-friendly)
sudo -- sh -c -e "echo '$(docker-machine ip test)   api.virtual-vehicles.com' >> /etc/hosts";

# test the services
sh tests_color.sh $(docker-machine ip test)
# alternate: sh tests_color.sh api.virtual-vehicles.com

# delete all images and containers
docker rmi -f $(docker images -a -q) && \
docker rm -f $(docker ps -a -q)

# tear down: stop and remove 'test' environment when complete
docker-machine stop test && \
docker-machine rm test
```

<p><a href="https://programmaticponderings.files.wordpress.com/2015/08/integration-tests1.png"><img src="https://programmaticponderings.files.wordpress.com/2015/08/integration-tests1.png?w=620" alt="Integration Tests" style="border:0 solid #ffffff;"/></a></p>

### Browse the Project
* NGINX: http://api.virtual-vehicles.com
* NGINX: http://api.virtual-vehicles.com/nginx_status
* Kibana: http://api.virtual-vehicles.com:8200
* Elasticsearch: http://api.virtual-vehicles.com:9200
* Elasticsearch: http://api.virtual-vehicles.com:9200/_status?pretty
* Logspout: http://api.virtual-vehicles.com:8000/logs
* Graphite: http://api.virtual-vehicles.com:8500

<p><a href="https://programmaticponderings.files.wordpress.com/2015/07/elk-ports.png"><img class="aligncenter wp-image-5856 size-full" style="border:0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/07/elk-ports.png?w=620" alt="ELK Ports"/></a></p>
