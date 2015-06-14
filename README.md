# virtual-vehicles-docker
Repository for files related to containerizing [Virtual-Vehicles](https://github.com/garystafford/virtual-vehicles-demo) project, using Docker. See blog post series [here](http://wp.me/p1RD28-1pm). 

#### Overview ####
Example of building and running project[Virtual-Vehicles](https://github.com/garystafford/virtual-vehicles-demo) project using Docker, without any centralized orchestration, service discover, and API gateway. Containers rely on ```--link``` for local container DNS-based service discovery. Demonstrates the complexity and limitations of multi-container applications, without the use orchestration.

#### Start-Up ####
The Virtual-Vehicles service containers are built using project's Java 'prod' environment properties files. Important, start from this project's root directory to run the following series of commands.  

Start Graphite/StatsD container (_container 1 of 9_)
```sh
docker run -d --name graphite -p 8481:80 hopsoft/graphite-statsd
```
Start all MongoDB containers (_containers 2-5 of 9_)
```sh
docker run -d --name mongo_vehicle mongo && \
docker run -d --name mongo_valet mongo && \
docker run -d --name mongo_maintenance mongo && \
docker run -d --name mongo_authentication mongo
```
Build each Virtual-Vehicle image and start each container (_containers 6-9 of 9_)  
_You can combine all (4) commands if you want to save time_
```sh
docker build -t virtual-vehicles:authentication \
-f virtual-vehicles-authentication-docker/Dockerfile . && \
docker run -d -p 8587:8587 --name authentication \
--link graphite:graphite \
--link mongo_authentication:mongo_authentication \
virtual-vehicles:authentication
```
```sh
docker build -t virtual-vehicles:vehicle \
-f virtual-vehicles-vehicle-docker/Dockerfile . && \
docker run -d -p 8581:8581 --name vehicle \
--link graphite:graphite \
--link mongo_vehicle:mongo_vehicle \
--link authentication:authentication \
virtual-vehicles:vehicle
```
```sh
docker build -t virtual-vehicles:maintenance \
-f virtual-vehicles-maintenance-docker/Dockerfile . && \
docker run -d -p 8583:8583 --name maintenance \
--link graphite:graphite \
--link mongo_maintenance:mongo_maintenance \
--link authentication:authentication \
virtual-vehicles:maintenance
```
```sh
docker build -t virtual-vehicles:valet \
-f virtual-vehicles-valet-docker/Dockerfile . && \
docker run -d -p 8585:8585 --name valet \
--link graphite:graphite \
--link mongo_valet:mongo_valet \
--link authentication:authentication \
virtual-vehicles:valet
```
View all Virtual-Vehicles related images
```sh
docker images | grep 'virtual-vehicles\|mongo\|hopsoft/graphite-statsd' | awk '{print $0}'
```
View all Virtual-Vehicles related containers
```sh
docker ps -a | grep 'virtual-vehicles\|mongo_\|graphite' | awk '{print $0}'
```
Check Virtual-Vehicles service container logs for start-up errors
```sh
docker logs vehicle && \
docker logs maintenance && \
docker logs valet && \
docker logs authentication
```
Enter a running container example  
_Use a 'ctrl-p', 'cntr-q' to exit vs. 'exit' to keep running_
```sh
docker exec -i -t "vehicle" /bin/bash
```
#### Cleaning Up ####
__CAUTION!__  
Stop and remove (4) 'virtual-vehicles' service containers and images
```sh
docker ps -a --no-trunc | grep 'virtual-vehicles' | awk '{print $1}' | xargs -r --no-run-if-empty docker stop && \
docker ps -a --no-trunc | grep 'virtual-vehicles' | awk '{print $1}' | xargs -r --no-run-if-empty docker rm && \
docker images --no-trunc | grep 'virtual-vehicles' | awk '{print $3}' | xargs -r --no-run-if-empty docker rmi
```
__CAUTION!__  
Stop and remove __ALL__ (8) 'virtual-vehicles' related containers and (4) 'virtual-vehicles' service images, leaving only the 'mongo' and 'hopsoft/graphite-statsd' images
```sh
docker ps -a --no-trunc | grep 'virtual-vehicles\|mongo_\|graphite' | awk '{print $1}' | xargs -r --no-run-if-empty docker stop && \
docker ps -a --no-trunc | grep 'virtual-vehicles\|mongo_\|graphite' | awk '{print $1}' | xargs -r --no-run-if-empty docker rm && \
docker images --no-trunc | grep 'virtual-vehicles\|mongo_\|graphite' | awk '{print $3}' | xargs -r --no-run-if-empty docker rmi
```
  
_README.md built with [dillinger.io](dillinger.io)_