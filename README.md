###Continuous Integration and Delivery of Microservices using Jenkins CI, Docker Machine, and Docker Compose###

<i>Continuously integrate and deploy and test a RestExpress microservices-based, multi-container, Java EE application to a virtual test environment, using Docker, Docker Hub, Docker Machine, Docker Compose, Jenkins CI, Maven, and VirtualBox.</i>

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-with-ambassador.png"><img class="aligncenter wp-image-5833 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-with-ambassador.png" alt="Docker Machine with Ambassador" /></a>
<h3>Introduction</h3>
In the last <a href="https://programmaticponderings.wordpress.com/2015/06/22/continuous-integration-and-delivery-of-microservices-using-jenkins-ci-maven-and-docker-compose/">post</a>, we learned how to use <a href="https://jenkins-ci.org/">Jenkins CI</a>, <a href="https://maven.apache.org/">Maven</a>, and <a href="https://docs.docker.com/compose/">Docker Compose</a> to take a set of microservices all the way from source control on <a href="https://github.com/">GitHub</a>, to a fully tested and running set of integrated <a href="https://docs.docker.com/articles/basics/">Docker containers</a>. We built the microservices, <a href="https://docs.docker.com/docker/userguide/dockerimages/">Docker images</a>, and <a href="https://docs.docker.com/articles/basics/">Docker containers</a>. We deployed the containers directly onto the Jenkins CI Server machine. Finally, we performed <a href="https://en.wikipedia.org/wiki/Integration_testing">integration tests</a> to ensure the services were functioning as expected, within the containers.

In a more mature continuous delivery model, we would have deployed the running containers to a fresh 'production-like' environment to be more accurately tested, not the Jenkins CI Server host machine. In this post, we will learn how to use the recently released <a href="https://docs.docker.com/machine/">Docker Machine</a> to create a fresh test environment in which to build and host our project's ten Docker containers. We will couple Docker Machine with Oracle's <a href="https://www.virtualbox.org/">VirtualBox</a>, <a href="https://jenkins-ci.org/">Jenkins CI,</a> and <a href="https://docs.docker.com/compose/">Docker Compose</a> to automatically build and test the services within their containers, within the virtual 'test' environment.

<span style="color: #ff0000;">Update: All code for this post is available on <a style="color: #ff0000;" href="https://github.com/garystafford/virtual-vehicles-docker/releases/tag/v2.1.0">GitHub</a>, release version v2.1.0 on the 'master' branch (after running git clone ..., run a 'git checkout tags/v2.1.0' command).</span>

<span style="color: #111111; font-family: Merriweather, Georgia, Times, serif; font-size: 1.3em;">Docker Machine</span>

If you recall in the last <a href="https://programmaticponderings.wordpress.com/2015/06/22/continuous-integration-and-delivery-of-microservices-using-jenkins-ci-maven-and-docker-compose/">post</a>, after compiling and packaging the microservices, Jenkins was used to deploy the build artifacts to the Virtual-Vehicles Docker GitHub project, as shown below.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-results1.png"><img class="aligncenter wp-image-5721 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-results1.png" alt="Build and Deploy Results" /></a>

We then used Jenkins, with the <a href="https://docs.docker.com/reference/commandline/cli/">Docker CLI</a> and the <a href="https://docs.docker.com/compose/cli/">Docker Compose CLI</a>, to automatically build and test the images and containers. This step will not change, however first we will use Docker Machine to automatically build a test environment, in which we will build the Docker images and containers.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-with-ambassador.png"><img class="aligncenter wp-image-5833 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-with-ambassador.png" alt="Docker Machine with Ambassador" /></a>

I've copied and modified the second Jenkins job we used in the last post, as shown below. The new job is titled, 'Virtual-Vehicles_Docker_Machine'. This will replace the previous job, 'Virtual-Vehicles_Docker_Compose'.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-jobs-machine.png"><img class="aligncenter wp-image-5771 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-jobs-machine.png" alt="Jenkins CI Jobs Machine" /></a>

The first step in the new Jenkins job is to clone the <a href="https://github.com/garystafford/virtual-vehicles-docker/releases/tag/v1.0.0">Virtual-Vehicles Docker GitHub repository</a>.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-machine-config-1.png"><img class="aligncenter wp-image-5773 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-machine-config-1.png" alt="Jenkins CI Machine Config 1" /></a>

Next, Jenkins run a bash script to automatically build the test VM with Docker Machine, build the Docker images and containers with Docker Compose within the new VM, and finally test the services.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-machine-config-21.png"><img class="aligncenter wp-image-5785 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-machine-config-21.png" alt="Jenkins CI Machine Config 2" /></a>

The bash script executed by Jenkins contains the following commands:

```bash
# optional: record current versions of docker apps with each build
docker -v && docker-compose -v && docker-machine -v

# set-up: clean up any previous machine failures
docker-machine stop test || echo "nothing to stop" && \
docker-machine rm test   || echo "nothing to remove"

# use docker-machine to create and configure 'test' environment
# add a -D (debug) if having issues
docker-machine create --driver virtualbox test
eval "$(docker-machine env test)"

# use docker-compose to pull and build new images and containers
docker-compose -p jenkins up -d

# optional: list machines, images, and containers
docker-machine ls && docker images && docker ps -a

# wait for containers to fully start before tests fire up
sleep 30

# test the services
sh tests.sh $(docker-machine ip test)

# tear down: stop and remove 'test' environment
docker-machine stop test && docker-machine rm test
```

As the above script shows, first Jenkins uses the <a href="https://docs.docker.com/machine/">Docker Machine CLI</a> to build and activate the 'test' virtual machine, using the <a href="https://www.virtualbox.org/">VirtualBox</a> driver. As of docker-machine version 0.3.0, the VirtualBox driver requires at least <a href="https://www.virtualbox.org/wiki/Downloads">VirtualBox 4.3.28</a> to be installed.

```bash
docker-machine create --driver virtualbox test
eval "$(docker-machine env test)"
```

Once this step is complete you will have the following VirtualBox VM created, running, and active.

```text
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM
test   *        virtualbox   Running   tcp://192.168.99.100:2376
```

Next, Jenkins uses the <a href="https://docs.docker.com/compose/cli/">Docker Compose CLI</a> to execute the project's <a href="https://docs.docker.com/compose/yml/">Docker Compose YAML file</a>.

```bash
docker-compose -p jenkins up -d
```

The YAML file directs Docker Compose to pull and build the required Docker images, and to build and configure the Docker containers.

```yaml
########################################################################
#
# title: Docker Compose YAML file for Virtual-Vehicles Project
# author: Gary A. Stafford (https://programmaticponderings.com)
# url: https://github.com/garystafford/virtual-vehicles-docker
# description: Pulls (5) images, builds (5) images, and builds (11) containers,
# for the Virtual-Vehicles Java microservices example REST API
# to run: docker-compose -p &lt;your_project_name_here&gt; up -d
#
########################################################################

graphite:
image: hopsoft/graphite-statsd:latest
ports:
- "8500:80"

mongoAuthentication:
image: mongo:latest

mongoValet:
image: mongo:latest

mongoMaintenance:
image: mongo:latest

mongoVehicle:
image: mongo:latest

authentication:
build: authentication/
links:
- graphite
- mongoAuthentication
- "ambassador:nginx"
expose:
- "8587"

valet:
build: valet/
links:
- graphite
- mongoValet
- "ambassador:nginx"
expose:
- "8585"

maintenance:
build: maintenance/
links:
- graphite
- mongoMaintenance
- "ambassador:nginx"
expose:
- "8583"

vehicle:
build: vehicle/
links:
- graphite
- mongoVehicle
- "ambassador:nginx"
expose:
- "8581"

nginx:
build: nginx/
ports:
- "80:80"
links:
- "ambassador:vehicle"
- "ambassador:valet"
- "ambassador:authentication"
- "ambassador:maintenance"

ambassador:
image: cpuguy83/docker-grand-ambassador
volumes:
- "/var/run/docker.sock:/var/run/docker.sock"
command: "-name jenkins_nginx_1 -name jenkins_authentication_1 -name jenkins_maintenance_1 -name jenkins_valet_1 -name jenkins_vehicle_1"
```

Running the <code>docker-compose.yaml</code> file, will pull these (5) Docker Hub images:

```text
REPOSITORY                           TAG          IMAGE ID
==========                           ===          ========
java                                 8u45-jdk     1f80eb0f8128
nginx                                latest       319d2015d149
mongo                                latest       66b43e3cae49
hopsoft/graphite-statsd              latest       b03e373279e8
cpuguy83/docker-grand-ambassador     latest       c635b1699f78
```

And, build these (5) Docker images from Dockerfiles:

```text
REPOSITORY                  TAG          IMAGE ID
==========                  ===          ========
jenkins_nginx               latest       0b53a9adb296
jenkins_vehicle             latest       d80f79e605f4
jenkins_valet               latest       cbe8bdf909b8
jenkins_maintenance         latest       15b8a94c00f4
jenkins_authentication      latest       ef0345369079
```

And, build these (11) Docker containers from corresponding image:

```text
CONTAINER ID     IMAGE                                NAME
============     =====                                ====
17992acc6542     jenkins_nginx                        jenkins_nginx_1
bcbb2a4b1a7d     jenkins_vehicle                      jenkins_vehicle_1
4ac1ac69f230     mongo:latest                         jenkins_mongoVehicle_1
bcc8b9454103     jenkins_valet                        jenkins_valet_1
7c1794ca7b8c     jenkins_maintenance                  jenkins_maintenance_1
2d0e117fa5fb     jenkins_authentication               jenkins_authentication_1
d9146a1b1d89     hopsoft/graphite-statsd:latest       jenkins_graphite_1
56b34cee9cf3     cpuguy83/docker-grand-ambassador     jenkins_ambassador_1
a72199d51851     mongo:latest                         jenkins_mongoAuthentication_1
307cb2c01cc4     mongo:latest                         jenkins_mongoMaintenance_1
4e0807431479     mongo:latest                         jenkins_mongoValet_1
```

Since we are connected to the brand new Docker Machine 'test' VM, there are no locally cached Docker images. All images required to build the containers must be pulled from <a href="https://hub.docker.com/">Docker Hub</a>. The build time will be 3-4x as long as the last post's build, which used the cached Docker images on the Jenkins CI machine.
<h3>Integration Testing</h3>
As in the last <a href="https://programmaticponderings.wordpress.com/2015/06/22/continuous-integration-and-delivery-of-microservices-using-jenkins-ci-maven-and-docker-compose/">post</a>, once the containers are built and configured, we run a series of expanded integration tests to confirm the containers and services are working. One difference, this time we will pass a parameter to the test bash script file:

```bash
sh tests.sh $(docker-machine ip test)
```

The parameter is the hostname used in the test's RESTful service calls. The parameter, <code>$(docker-machine ip test)</code>, is translated to the IP address of the 'test' VM. In our example, <code>192.168.99.100</code>. If a parameter is not provided, the test script's <code>hostname</code> variable will use the default value of <code>localhost</code>, '<code>hostname=${1-'localhost'}</code>'.

Another change since the last post, the project now uses the open source version of <a href="http://wiki.nginx.org/Main">Nginx</a>, the free, open-source, high-performance HTTP server and reverse proxy, as a pseudo-API gateway. Instead calling each microservice directly, using their individual ports (i.e. port <code>8581</code> for the Vehicle microservice), all traffic is sent through Nginx on default http port 80, for example:

```bash
http://192.168.99.100/vehicles/utils/ping.json
http://192.168.99.100/jwts?apiKey=Z1nXG8JGKwvGlzQgPLwQdndW&amp;secret=ODc4OGNiNjE5ZmI
http://192.168.99.100/vehicles/558f3042e4b0e562c03329ad
```

Internal traffic between the microservices and MongoDB, and between the microservices and <a href="http://graphite.wikidot.com/">Graphite</a> is still direct, using Docker container <a href="https://docs.docker.com/userguide/dockerlinks/">linking</a>. Traffic between the microservices and Nginx, in both directions, is handled by an <a href="https://docs.docker.com/articles/ambassador_pattern_linking/">ambassador container</a>, a common pattern. Nginx acts as a <a href="https://en.wikipedia.org/wiki/Reverse_proxy">reverse proxy</a> for the microservices. Using Nginx brings us closer to a truer production-like experience for testing the services.

```bash
#!/bin/sh

########################################################################
#
# title: Virtual-Vehicles Project Integration Tests
# author: Gary A. Stafford (https://programmaticponderings.com)
# url: https://github.com/garystafford/virtual-vehicles-docker
# description: Performs integration tests on the Virtual-Vehicles
# microservices
# to run: sh tests.sh
# docker-machine: sh tests.sh $(docker-machine ip test)
#
########################################################################

echo --- Integration Tests ---
echo

### VARIABLES ###
hostname=${1-'localhost'} # use input param or default to localhost
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | sha256sum | base64 | head -c 15)" # randomized
make="Test"
model="Foo"

echo hostname: ${hostname}
echo application: ${application}
echo secret: ${secret}
echo make: ${make}
echo model: ${model}
echo

### TESTS ###
echo "TEST: GET request should return 'true' in the response body"
url="http://${hostname}/vehicles/utils/ping.json"
echo ${url}
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
--url "${url}" \
| grep true &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "TEST: POST request should return a new client in the response body with an 'id'"
url="http://${hostname}/clients"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" -d "{
\"application\": \"${application}\",
\"secret\": \"${secret}\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "SETUP: Get the new client's apiKey for next test"
url="http://${hostname}/clients"
echo ${url}
apiKey=$(curl -X POST -H "Cache-Control: no-cache" -d "{
\"application\": \"${application}\",
\"secret\": \"${secret}\"
}" --url "${url}" \
| grep -o '"apiKey":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| sed -e 's/^"//' -e 's/"$//')
echo apiKey: ${apiKey}
echo

echo "TEST: GET request should return a new jwt in the response body"
url="http://${hostname}/jwts?apiKey=${apiKey}&amp;secret=${secret}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "SETUP: Get a new jwt using the new client for the next test"
url="http://${hostname}/jwts?apiKey=${apiKey}&amp;secret=${secret}"
echo ${url}
jwt=$(curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
| sed -e 's/^"//' -e 's/"$//')
echo jwt: ${jwt}
echo

echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
url="http://${hostname}/vehicles"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d "{
\"year\": 2015,
\"make\": \"${make}\",
\"model\": \"${model}\",
\"color\": \"White\",
\"type\": \"Sedan\",
\"mileage\": 250
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}/vehicles?filter=make::${make}|model::${model}&amp;limit=1"
echo ${url}
id=$(curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| tail -1 \
| sed -e 's/^"//' -e 's/"$//')
echo vehicle id: ${id}
echo

echo "TEST: GET request should return a vehicle in the response body with the requested 'id'"
url="http://${hostname}/vehicles/${id}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "TEST: POST request should return a new maintenance record in the response body with an 'id'"
url="http://${hostname}/maintenances"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d "{
\"vehicleId\": \"${id}\",
\"serviceDateTime\": \"2015-27-00T15:00:00.400Z\",
\"mileage\": 1000,
\"type\": \"Test Maintenance\",
\"notes\": \"This is a test notes.\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo

echo "TEST: POST request should return a new valet transaction in the response body with an 'id'"
url="http://${hostname}/valets"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d "{
\"vehicleId\": \"${id}\",
\"dateTimeIn\": \"2015-27-00T15:00:00.400Z\",
\"parkingLot\": \"Test Parking Ramp\",
\"parkingSpot\": 10,
\"notes\": \"This is a test notes.\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' &gt; /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
echo
```

<h3>Tear Down</h3>
In true continuous integration fashion, once the integration tests have completed, we tear down the project by removing the VirtualBox 'test' VM. This also removed all images and containers.

```bash
docker-machine stop test && \
docker-machine rm test
```

<h3>Jenkins CI Console Output</h3>
Below is an abridged sample of what the Jenkins CI console output will look like from a successful 'build'.

```text
Started by user anonymous
Building in workspace /var/lib/jenkins/jobs/Virtual-Vehicles_Docker_Machine/workspace
&gt; git rev-parse --is-inside-work-tree # timeout=10
Fetching changes from the remote Git repository
&gt; git config remote.origin.url https://github.com/garystafford/virtual-vehicles-docker.git # timeout=10
Fetching upstream changes from https://github.com/garystafford/virtual-vehicles-docker.git
&gt; git --version # timeout=10
using GIT_SSH to set credentials
using .gitcredentials to set credentials
&gt; git config --local credential.helper store --file=/tmp/git7588068314920923143.credentials # timeout=10
&gt; git -c core.askpass=true fetch --tags --progress https://github.com/garystafford/virtual-vehicles-docker.git +refs/heads/*:refs/remotes/origin/*
&gt; git config --local --remove-section credential # timeout=10
&gt; git rev-parse refs/remotes/origin/master^{commit} # timeout=10
&gt; git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision f473249f0f70290b75cb320909af1f57cdaf2aa5 (refs/remotes/origin/master)
&gt; git config core.sparsecheckout # timeout=10
&gt; git checkout -f f473249f0f70290b75cb320909af1f57cdaf2aa5
&gt; git rev-list f473249f0f70290b75cb320909af1f57cdaf2aa5 # timeout=10
[workspace] $ /bin/sh -xe /tmp/hudson8587699987350884629.sh

+ docker -v
Docker version 1.7.0, build 0baf609
+ docker-compose -v
docker-compose version: 1.3.1
CPython version: 2.7.9
OpenSSL version: OpenSSL 1.0.1e 11 Feb 2013
+ docker-machine -v
docker-machine version 0.3.0 (0a251fe)

+ docker-machine stop test
+ docker-machine rm test
Successfully removed test

+ docker-machine create --driver virtualbox test
Creating VirtualBox VM...
Creating SSH key...
Starting VirtualBox VM...
Starting VM...
To see how to connect Docker to this machine, run: docker-machine env test
+ docker-machine env test
+ eval export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/var/lib/jenkins/.docker/machine/machines/test"
export DOCKER_MACHINE_NAME="test"
# Run this command to configure your shell:
# eval "$(docker-machine env test)"
+ export DOCKER_TLS_VERIFY=1
+ export DOCKER_HOST=tcp://192.168.99.100:2376
+ export DOCKER_CERT_PATH=/var/lib/jenkins/.docker/machine/machines/test
+ export DOCKER_MACHINE_NAME=test
+ docker-compose -p jenkins up -d
Pulling mongoValet (mongo:latest)...
latest: Pulling from mongo

...Abridged output...

+ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM
test   *        virtualbox   Running   tcp://192.168.99.100:2376
+ docker images
REPOSITORY                         TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
jenkins_vehicle                    latest              fdd7f9d02ff7        2 seconds ago       837.1 MB
jenkins_valet                      latest              8a592e0fe69a        4 seconds ago       837.1 MB
jenkins_maintenance                latest              5a4a44e136e5        5 seconds ago       837.1 MB
jenkins_authentication             latest              e521e067a701        7 seconds ago       838.7 MB
jenkins_nginx                      latest              085d183df8b4        25 minutes ago      132.8 MB
java                               8u45-jdk            1f80eb0f8128        12 days ago         816.4 MB
nginx                              latest              319d2015d149        12 days ago         132.8 MB
mongo                              latest              66b43e3cae49        12 days ago         260.8 MB
hopsoft/graphite-statsd            latest              b03e373279e8        4 weeks ago         740 MB
cpuguy83/docker-grand-ambassador   latest              c635b1699f78        5 months ago        525.7 MB

+ docker ps -a
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                                      NAMES
4ea39fa187bf        jenkins_vehicle                    "java -classpath .:c   2 seconds ago       Up 1 seconds        8581/tcp                                   jenkins_vehicle_1
b248a836546b        mongo:latest                       "/entrypoint.sh mong   3 seconds ago       Up 3 seconds        27017/tcp                                  jenkins_mongoVehicle_1
0c94e6409afc        jenkins_valet                      "java -classpath .:c   4 seconds ago       Up 3 seconds        8585/tcp                                   jenkins_valet_1
657f8432004b        jenkins_maintenance                "java -classpath .:c   5 seconds ago       Up 5 seconds        8583/tcp                                   jenkins_maintenance_1
8ff6de1208e3        jenkins_authentication             "java -classpath .:c   7 seconds ago       Up 6 seconds        8587/tcp                                   jenkins_authentication_1
c799d5f34a1c        hopsoft/graphite-statsd:latest     "/sbin/my_init"        12 minutes ago      Up 12 minutes       2003/tcp, 8125/udp, 0.0.0.0:8500-&gt;80/tcp   jenkins_graphite_1
040872881b25        jenkins_nginx                      "nginx -g 'daemon of   25 minutes ago      Up 25 minutes       0.0.0.0:80-&gt;80/tcp, 443/tcp                jenkins_nginx_1
c6a2dc726abc        mongo:latest                       "/entrypoint.sh mong   26 minutes ago      Up 26 minutes       27017/tcp                                  jenkins_mongoAuthentication_1
db22a44239f4        mongo:latest                       "/entrypoint.sh mong   26 minutes ago      Up 26 minutes       27017/tcp                                  jenkins_mongoMaintenance_1
d5fd655474ba        cpuguy83/docker-grand-ambassador   "/usr/bin/grand-amba   26 minutes ago      Up 26 minutes                                                  jenkins_ambassador_1
2b46bd6f8cfb        mongo:latest                       "/entrypoint.sh mong   31 minutes ago      Up 31 minutes       27017/tcp                                  jenkins_mongoValet_1

+ sleep 30

+ docker-machine ip test
+ sh tests.sh 192.168.99.100

--- Integration Tests ---

hostname: 192.168.99.100
application: Test API Client 1435585062
secret: NGM5OTI5ODAxMTZ
make: Test
model: Foo

TEST: GET request should return 'true' in the response body
http://192.168.99.100/vehicles/utils/ping.json
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100     4    0     4    0     0     26      0 --:--:-- --:--:-- --:--:--    25
100     4    0     4    0     0     26      0 --:--:-- --:--:-- --:--:--    25
RESULT: pass

TEST: POST request should return a new client in the response body with an 'id'
http://192.168.99.100/clients
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   399    0   315  100    84    847    225 --:--:-- --:--:-- --:--:--   849
RESULT: pass

SETUP: Get the new client's apiKey for next test
http://192.168.99.100/clients
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   399    0   315  100    84  20482   5461 --:--:-- --:--:-- --:--:-- 21000
apiKey: sv1CA9NdhmXh72NrGKBN3Abb

TEST: GET request should return a new jwt in the response body
http://192.168.99.100/jwts?apiKey=sv1CA9NdhmXh72NrGKBN3Abb&amp;secret=NGM5OTI5ODAxMTZ
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   222    0   222    0     0    686      0 --:--:-- --:--:-- --:--:--   687
RESULT: pass

SETUP: Get a new jwt using the new client for the next test
http://192.168.99.100/jwts?apiKey=sv1CA9NdhmXh72NrGKBN3Abb&amp;secret=NGM5OTI5ODAxMTZ
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   222    0   222    0     0  16843      0 --:--:-- --:--:-- --:--:-- 17076
jwt: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhcGkudmlydHVhbC12ZWhpY2xlcy5jb20iLCJhcGlLZXkiOiJzdjFDQTlOZGhtWGg3Mk5yR0tCTjNBYmIiLCJleHAiOjE0MzU2MjEwNjMsImFpdCI6MTQzNTU4NTA2M30.WVlhIhUcTz6bt3iMVr6MWCPIDd6P0aDZHl_iUd6AgrM

TEST: POST request should return a new vehicle in the response body with an 'id'
http://192.168.99.100/vehicles
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   123    0     0  100   123      0    612 --:--:-- --:--:-- --:--:--   611
100   419    0   296  100   123    649    270 --:--:-- --:--:-- --:--:--   649
RESULT: pass

SETUP: Get id from new vehicle for the next test
http://192.168.99.100/vehicles?filter=make::Test|model::Foo&amp;limit=1
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   377    0   377    0     0   5564      0 --:--:-- --:--:-- --:--:--  5626
vehicle id: 55914a28e4b04658471dc03a

TEST: GET request should return a vehicle in the response body with the requested 'id'
http://192.168.99.100/vehicles/55914a28e4b04658471dc03a
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   296    0   296    0     0   7051      0 --:--:-- --:--:-- --:--:--  7219
RESULT: pass

TEST: POST request should return a new maintenance record in the response body with an 'id'
http://192.168.99.100/maintenances
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   565    0   376  100   189    506    254 --:--:-- --:--:-- --:--:--   506
100   565    0   376  100   189    506    254 --:--:-- --:--:-- --:--:--   506
RESULT: pass

TEST: POST request should return a new valet transaction in the response body with an 'id'
http://192.168.99.100/valets
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed

0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   561    0   368  100   193    514    269 --:--:-- --:--:-- --:--:--   514
RESULT: pass

+ docker-machine stop test
+ docker-machine rm test
Successfully removed test

Finished: SUCCESS
```

<h3>Graphite and Statsd</h3>
If you've chose to build the Virtual-Vehicles Docker project outside of Jenkins CI, then in addition running the test script and using applications like Postman to test the Virtual-Vehicles RESTful API, you may also use <a href="http://graphite.readthedocs.org/en/latest/overview.html">Graphite</a> and <a href="https://github.com/etsy/statsd/wiki">StatsD</a>. RestExpress comes fully configured out of the box with Graphite integration, through the <a href="https://dropwizard.github.io/metrics/3.1.0/">Metrics plugin</a>. The Virtual-Vehicles RESTful API example is configured to use port 8500 to access the Graphite UI. The Virtual-Vehicles RESTful API example uses the <a href="https://registry.hub.docker.com/u/hopsoft/graphite-statsd/">hopsoft/graphite-statsd</a> Docker image to build the Graphite/StatsD Docker container.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/graphite-dashboard.png"><img class="aligncenter wp-image-5838 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/graphite-dashboard.png" alt="Graphite Dashboard" /></a>
<h3>The Complete Process</h3>
The below diagram show the entire Virtual-Vehicles continuous integration and delivery process, start to finish, using Docker, Docker Hub, Docker Machine, Docker Compose, Jenkins CI, Maven, RestExpress, and VirtualBox.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-full-process.png"><img class="aligncenter wp-image-5832 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-machine-full-process.png" alt="Docker Machine Full Process" /></a>