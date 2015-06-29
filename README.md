<i>Continuously build, test, package and deploy a microservices-based, multi-container, Java EE application using Jenkins CI, Maven, Docker, and Docker Compose</i>

<a href="https://programmaticponderings.files.wordpress.com/2015/06/introdockercompose.png"><img class="aligncenter wp-image-5669 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/introdockercompose.png" alt="IntroDockerCompose" width="660" height="329" /></a>
<h3>Previous Posts</h3>
In the previous 3-part series, <a href="https://programmaticponderings.wordpress.com/2015/05/18/building-a-microservices-based-rest-api-with-restexpress-java-and-mongodb-part-1/">Building a Microservices-based REST API with RestExpress, Java EE, and MongoDB</a>, we developed a set of Java EE-based microservices, which formed the Virtual-Vehicles REST API. In <a title="Building a Microservices-based REST API with RestExpress, Java EE, and MongoDB: Part 1" href="https://programmaticponderings.wordpress.com/2015/05/18/building-a-microservices-based-rest-api-with-restexpress-java-and-mongodb-part-1/">Part One</a> of this series, we introduced the concepts of a RESTful API and microservices, using the vehicle-themed Virtual-Vehicles REST API example. In <a href="https://programmaticponderings.wordpress.com/2015/05/31/building-a-microservices-based-rest-api-with-restexpress-java-ee-and-mongodb-part-2/">Part Two</a>, we gained a basic understanding of how RestExpress works to build microservices, and discovered how to get the microservices example up and running. Lastly, in <a href="https://programmaticponderings.wordpress.com/2015/06/05/building-a-microservices-based-rest-api-with-restexpress-java-ee-and-mongodb-part-3/">Part Three</a>, we explored how to use tools such as Postman, along with the API documentation, to test our microservices.
<h3>Introduction</h3>
In this post, we will demonstrate how to use <a href="https://jenkins-ci.org/">Jenkins CI</a>, <a href="https://maven.apache.org/">Maven</a>, and <a href="https://docs.docker.com/compose/">Docker Compose</a> to take our set of microservices all the way from source control on <a href="https://github.com/">GitHub</a>, to a fully tested and running set of integrated and orchestrated <a href="https://docs.docker.com/articles/basics/">Docker containers</a>. We will build and test the microservices, <a href="https://docs.docker.com/docker/userguide/dockerimages/">Docker images</a>, and <a href="https://docs.docker.com/articles/basics/">Docker containers</a>. We will deploy the containers and perform <a href="https://en.wikipedia.org/wiki/Integration_testing">integration tests</a> to ensure the services are functioning as expected, within the containers. The milestones in our process will be:
<ol>
	<li><span style="text-decoration: underline;">Continuous Integration</span>: Using Jenkins CI and Maven, automatically compile, test, and package the individual microservices</li>
	<li><span style="text-decoration: underline;">Deployment</span>: Using Jenkins, automatically deploy the build artifacts to the new Virtual-Vehicles Docker project</li>
	<li><span style="text-decoration: underline;">Containerization</span>: Using Jenkins and Docker Compose, automatically build the Docker images and containers from the build artifacts and a set of Dockerfiles</li>
	<li><span style="text-decoration: underline;">Integration Testing</span>: Using Jenkins, perform automated integration tests on the containerized services</li>
	<li><span style="text-decoration: underline;">Tear Down</span>: Using Jenkins, automatically stop and remove the containers and images</li>
</ol>
For brevity, we will deploy the containers directly to the Jenkins CI Server, where they were built. In an upcoming post, I will demonstrate how to use the recently released <a href="https://docs.docker.com/machine/">Docker Machine</a> to host the containers within an isolated VM.

All code for this post is available on <a href="https://github.com/garystafford/virtual-vehicles-docker/releases/tag/v1.0.0">GitHub</a>, release version 1.0.0.
<h3>Build the Microservices</h3>
In order to host the Virtual-Vehicles microservices, we must first compile the source code and produce build artifacts. In the case of the Virtual-Vehicles example, the build artifacts are a <a href="https://en.wikipedia.org/wiki/JAR_(file_format)">JAR file</a> and at least one environment-specific properties file. In <a href="https://programmaticponderings.wordpress.com/2015/05/31/building-a-microservices-based-rest-api-with-restexpress-java-ee-and-mongodb-part-2/">Part Two</a> of our previous series, we compiled and produced JAR files for our microservices from the command line using Maven.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/builddeploy.png"><img class="aligncenter wp-image-5744 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/builddeploy.png" alt="Build and Deploy" width="594" height="523" /></a>

To automatically build our Maven-based microservices project in this post, we will use Jenkins CI and the Jenkins <a href="https://wiki.jenkins-ci.org/display/JENKINS/Maven+Project+Plugin">Maven Project Plugin</a>. The Virtual-Vehicles microservices are bundled together into what Maven considers a <a href="http://books.sonatype.com/mvnex-book/reference/multimodule.html">multi-module project</a>, which is defined by a parent POM referring to one or more sub-modules. Using the concept of <a href="https://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Example_3">project inheritance</a>, Jenkins will compile each of the four microservices from the project's single parent POM file. Note the four modules at the end of the <code>pom.xml</code> below, corresponding to each microservice.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <name>Virtual-Vehicles API</name>
    <description>Virtual-Vehicles API
        https://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Example_3
    </description>
    <url>https://github.com/garystafford/virtual-vehicle-demo</url>
    <groupId>com.example</groupId>
    <artifactId>Virtual-Vehicles-API</artifactId>
    <version>1</version>
    <packaging>pom</packaging>

    <modules>
        <module>Maintenance</module>
        <module>Valet</module>
        <module>Vehicle</module>
        <module>Authentication</module>
    </modules>
</project>
```
Below is the view of the four individual Maven modules, within the single Jenkins Maven job.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/maven-modules-in-jenkins1.png"><img class="aligncenter wp-image-5727 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/maven-modules-in-jenkins1.png" alt="Maven Modules In Jenkins" width="660" height="409" /></a>

Each microservice module contains a Maven POM files. The POM files use the <a href="http://maven.apache.org/plugins/maven-compiler-plugin/">Apache Maven Compiler Plugin</a> to compile code, and the <a href="https://maven.apache.org/plugins/maven-shade-plugin/">Apache Maven Shade Plugin</a> to create 'uber-jars' from the compiled code. The Shade plugin provides the capability to package the artifact in an uber-jar, including its dependencies. This will allow us to independently host the service in its own container, without external dependencies. Lastly, using the <a href="https://maven.apache.org/plugins/maven-resources-plugin/">Apache Maven Resources Plugin</a>, Maven will copy the environment properties files from the source directory to the 'target' directory, which contains the JAR file. To accomplish these Maven tasks, all Jenkins needs to do is a series of <a href="https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html">Maven life-cycle goals</a>: '<code>clean install package validate</code>'.

Once the code is compiled and packaged into uber-jars, Jenkins uses the <a href="https://wiki.jenkins-ci.org/display/JENKINS/ArtifactDeployer+Plugin">Artifact Deployer Plugin</a> to deploy the build artifacts from Jenkins' workspace to a remote location. In our example, we will copy the artifacts to a second GitHub project, from which we will containerize our microservices.

Shown below are the two Jenkins jobs. The first one compiles, packages, and deploys the build artifacts. The second job containerizes the services, databases, and monitoring application.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-main-page1.png"><img class="aligncenter wp-image-5694 size-large" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/jenkins-ci-main-page1.png?w=660" alt="Jenkins CI Main Page" width="660" height="434" /></a>

Shown below are two screen grabs showing how we clone the Virtual-Vehicles GitHub repository and build the project using the main parent <code>pom.xml</code> file. Building the parent POM, in-turn builds all the microservice modules, using their POM files.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-11.png"><img class="aligncenter wp-image-5720 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-11.png" alt="Build and Deploy Config 1" width="660" height="409" /></a>

<a href="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-21.png"><img class="aligncenter wp-image-5719 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-21.png" alt="Build and Deploy Config 2" width="660" height="409" /></a>
<h3>Deploy Build Artifacts</h3>
Once we have successfully compiled, tested (if we had unit tests with <a href="https://github.com/RestExpress/RestExpress">RestExpress</a>), and packages the build artifacts as uber-jars, we deploy each set of build artifacts to a subfolder within the Virtual-Vehicles Docker GitHub project, using Jenkins' <a href="https://wiki.jenkins-ci.org/display/JENKINS/ArtifactDeployer+Plugin">Artifact Deployer Plugin</a>. Shown below is the deployment configuration for just the Vehicles microservice. This deployment pattern is repeated for each service, within the Jenkins job configuration.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-31.png"><img class="aligncenter wp-image-5718 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-config-31.png" alt="Build and Deploy Config 3" width="660" height="409" /></a>

The Jenkins' <a href="https://wiki.jenkins-ci.org/display/JENKINS/ArtifactDeployer+Plugin">Artifact Deployer Plugin</a> also provides the convenient ability to view and to redeploy the artifacts. Below, you see a list of the microservice artifacts deployed to the Docker project by Jenkins.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-results1.png"><img class="aligncenter wp-image-5721 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/build-and-deploy-results1.png" alt="Build and Deploy Results" width="660" height="409" /></a>
<h3>Build and Compose the Containers</h3>
<a href="https://programmaticponderings.files.wordpress.com/2015/06/introdockercompose.png"><img class="aligncenter wp-image-5669 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/introdockercompose.png" alt="IntroDockerCompose" width="660" height="329" /></a>

The second Jenkins job clones the <a href="https://github.com/garystafford/virtual-vehicles-docker/releases/tag/v1.0.0">Virtual-Vehicles Docker GitHub repository</a>.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-1.png"><img class="aligncenter wp-image-5680 size-large" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-1.png?w=620" alt="Docker Compose Config 1" width="620" height="408" /></a>

The second Jenkins job executes commands from the shell prompt. The first commands use the <a href="https://docs.docker.com/reference/commandline/cli/">Docker CLI</a> to removes any existing images and containers, which might have been left over from previous job failures. The second commands use the <a href="https://docs.docker.com/compose/cli/">Docker Compose CLI</a> to execute the project's <a href="https://docs.docker.com/compose/yml/">Docker Compose YAML file</a>. The YAML file directs Docker Compose to pull and build the required Docker images, and to build and configure the Docker containers.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-1.png"><img class="aligncenter wp-image-5678 size-large" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-2.png?w=620" alt="Docker Compose Config 2" width="620" height="408" /></a>

```bash
# remove all images and containers from this build
docker ps -a --no-trunc  | grep 'jenkins' \
| awk '{print $1}' | xargs -r --no-run-if-empty docker stop && \
docker ps -a --no-trunc  | grep 'jenkins' \
| awk '{print $1}' | xargs -r --no-run-if-empty docker rm && \
docker images --no-trunc | grep 'jenkins' \
| awk '{print $3}' | xargs -r --no-run-if-empty docker rmi
```

```bash
# set DOCKER_HOST environment variable
export DOCKER_HOST=tcp://localhost:4243

# record installed version of Docker and Maven with each build
mvn --version && \
docker --version && \
docker-compose --version

# use docker-compose to build new images and containers
docker-compose -p jenkins up -d

# list virtual-vehicles related images
docker images | grep 'jenkins' | awk '{print $0}'

# list all containers
docker ps -a | grep 'jenkins\|mongo_\|graphite' | awk '{print $0}'
```

```yaml
########################################################################
#
# title:       Docker Compose YAML file for Virtual-Vehicles Project
# author:      Gary A. Stafford (https://programmaticponderings.com)
# url:         https://github.com/garystafford/virtual-vehicles-docker  
# description: Builds (4) images, pulls (2) images, and builds (9) containers,
#              for the Virtual-Vehicles Java microservices example REST API
# to run:      docker-compose -p virtualvehicles up -d
#
########################################################################

graphite:
  image: hopsoft/graphite-statsd:latest
  ports:
   - "8481:80"

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
  ports:
   - "8587:8587"
  links:
   - graphite
   - mongoAuthentication

valet:
  build: valet/
  ports:
   - "8585:8585"
  links:
   - graphite
   - mongoValet
   - authentication

maintenance:
  build: maintenance/
  ports:
   - "8583:8583"
  links:
   - graphite
   - mongoMaintenance
   - authentication

vehicle:
  build: vehicle/
  ports:
   - "8581:8581"
  links:
   - graphite
   - mongoVehicle
   - authentication
```
Running the <code>docker-compose.yaml</code> file, produces the following images:

```text
REPOSITORY                TAG        IMAGE ID
==========                ===        ========
jenkins_vehicle           latest     a6ea4dfe7cf5
jenkins_valet             latest     162d3102d43c
jenkins_maintenance       latest     0b6f530cc968
jenkins_authentication    latest     45b50487155e
```
And, these containers:

```text
CONTAINER ID     IMAGE                              NAME
============     =====                              ====
2b4d5a918f1f     jenkins_vehicle                    jenkins_vehicle_1
492fbd88d267     mongo:latest                       jenkins_mongoVehicle_1
01f410bb1133     jenkins_valet                      jenkins_valet_1
6a63a664c335     jenkins_maintenance                jenkins_maintenance_1
00babf484cf7     jenkins_authentication             jenkins_authentication_1
548a31034c1e     hopsoft/graphite-statsd:latest     jenkins_graphite_1
cdc18bbb51b4     mongo:latest                       jenkins_mongoAuthentication_1
6be5c0558e92     mongo:latest                       jenkins_mongoMaintenance_1
8b71d50a4b4d     mongo:latest                       jenkins_mongoValet_1
```
<h3>Integration Testing</h3>
Once the containers have been successfully built and configured, we run a series of integration tests to confirm the services are up and running. We refer to these tests as integration tests because they test the interaction of multiple components. Integration tests were covered in the last post, <a href="https://programmaticponderings.wordpress.com/2015/06/05/building-a-microservices-based-rest-api-with-restexpress-java-ee-and-mongodb-part-3/">Building a Microservices-based REST API with RestExpress, Java EE, and MongoDB: Part 3</a>.

Note the short pause I have inserted before running the tests. Docker Compose does an excellent job of accounting for the required start-up order of the containers to avoid <a href="http://blog.chmouel.com/2014/11/04/avoiding-race-conditions-between-containers-with-docker-and-fig/">race conditions</a> (see my previous <a href="https://programmaticponderings.wordpress.com/2014/11/30/preventing-race-conditions-between-containers-in-dockerized-mean-applications/">post</a>). However, depending on the speed of the host box, there is still a start-up period for the container's processes to be up, running, and ready to receive traffic. <a href="http://logging.apache.org/log4j/2.x/">Apache Log4j 2</a> and MongoDB startup, in particular, take extra time. I've seen the containers take as long as 1-2 minutes on a slow box to fully start. Without the pause, the tests fail with various errors, since the container's processes are not all running.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-3.png"><img class="aligncenter wp-image-5679 size-large" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/docker-compose-config-3.png?w=620" alt="Docker Compose Config 3" width="620" height="408" /></a>

```bash
sleep 15
sh tests.sh -v
```
The bash-based tests below just scratch the surface as a complete set of integration tests. However, they demonstrate an effective multi-stage testing pattern for handling the complex nature of RESTful service request requirements. The tests build upon each other. After setting up some variables, the tests register a new API client. Then, they use the new client's API key to obtain a JWT. The tests then use the JWT to authenticate themselves, and create a new vehicle. Finally, they use the new vehicle's id and the JWT to verify the existence for the new vehicle.

Although some may consider using bash to test somewhat primitive, the script demonstrates the effectiveness of bash's <code>curl</code>, <code>grep</code>, <code>sed</code>, <code>awk</code>, along with regular expressions, to test our RESTful services

```bash
#!/bin/sh

########################################################################
#
# title:       Virtual-Vehicles Project Integration Tests
# author:      Gary A. Stafford (https://programmaticponderings.com)
# url:         https://github.com/garystafford/virtual-vehicles-docker  
# description: Performs integration tests on the Virtual-Vehicles
#              microservices
# to run:      sh tests.sh -v
#
########################################################################

echo --- Integration Tests ---

### VARIABLES ###
hostname="localhost"
application="Test API Client $(date +%s)" # randomized
secret="$(date +%s | sha256sum | base64 | head -c 15)" # randomized

echo hostname: ${hostname}
echo application: ${application}
echo secret: ${secret}


### TESTS ###
echo "TEST: GET request should return 'true' in the response body"
url="http://${hostname}:8581/vehicles/utils/ping.json"
echo ${url}
curl -X GET -H 'Accept: application/json; charset=UTF-8' \
--url "${url}" \
| grep true > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"


echo "TEST: POST request should return a new client in the response body with an 'id'"
url="http://${hostname}:8587/clients"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" -d "{
    \"application\": \"${application}\",
    \"secret\": \"${secret}\"
}" --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"


echo "SETUP: Get the new client's apiKey for next test"
url="http://${hostname}:8587/clients"
echo ${url}
apiKey=$(curl -X POST -H "Cache-Control: no-cache" -d "{
    \"application\": \"${application}\",
    \"secret\": \"${secret}\"
}" --url "${url}" \
| grep -o '"apiKey":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| sed -e 's/^"//'  -e 's/"$//')
echo apiKey: ${apiKey}
echo

echo "TEST: GET request should return a new jwt in the response body"
url="http://${hostname}:8587/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"


echo "SETUP: Get a new jwt using the new client for the next test"
url="http://${hostname}:8587/jwts?apiKey=${apiKey}&secret=${secret}"
echo ${url}
jwt=$(curl -X GET -H "Cache-Control: no-cache" \
--url "${url}" \
| grep '[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}\.[a-zA-Z0-9_-]\{1,\}' \
| sed -e 's/^"//'  -e 's/"$//')
echo jwt: ${jwt}


echo "TEST: POST request should return a new vehicle in the response body with an 'id'"
url="http://${hostname}:8581/vehicles"
echo ${url}
curl -X POST -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
-d '{
    "year": 2015,
    "make": "Test",
    "model": "Foo",
    "color": "White",
    "type": "Sedan",
    "mileage": 250
}' --url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"


echo "SETUP: Get id from new vehicle for the next test"
url="http://${hostname}:8581/vehicles?filter=make::Test|model::Foo&limit=1"
echo ${url}
id=$(curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' \
| grep -o '[a-zA-Z0-9]\{24\}' \
| tail -1 \
| sed -e 's/^"//'  -e 's/"$//')
echo vehicle id: ${id}


echo "TEST: GET request should return a vehicle in the response body with the requested 'id'"
url="http://${hostname}:8581/vehicles/${id}"
echo ${url}
curl -X GET -H "Cache-Control: no-cache" \
-H "Authorization: Bearer ${jwt}" \
--url "${url}" \
| grep '"id":"[a-zA-Z0-9]\{24\}"' > /dev/null
[ "$?" -ne 0 ] && echo "RESULT: fail" && exit 1
echo "RESULT: pass"
```
Since these tests are just a bash script, they can also be ran separately from the command line, as in the screen grab below. The output, except for the colored text, is identical to what appears in the Jenkins console output.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/running-integration-tests.png"><img class="aligncenter wp-image-5714 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/running-integration-tests.png" alt="Tests from Terminal Prompt" width="656" height="673" /></a>
<h3>Tear Down</h3>
Once the integration tests have completed, we 'tear down' the project by removing the Virtual-Vehicle images and containers. We simply repeat the first commands we ran at the start of the Jenkins build phase. You could choose to remove the tear down step, and use this job as a way to simply build and start your multi-container application.

```bash
# remove all images and containers from this build
docker ps -a --no-trunc  | grep 'jenkins' \
| awk '{print $1}' | xargs -r --no-run-if-empty docker stop && \
docker ps -a --no-trunc  | grep 'jenkins' \
| awk '{print $1}' | xargs -r --no-run-if-empty docker rm && \
docker images --no-trunc | grep 'jenkins' \
| awk '{print $3}' | xargs -r --no-run-if-empty docker rmi
```
<h3>The Complete Process</h3>
The below diagram show the entire process, start to finish.

<a href="https://programmaticponderings.files.wordpress.com/2015/06/fullprocess.png"><img class="aligncenter wp-image-5745 size-full" style="border: 0 solid #ffffff;" src="https://programmaticponderings.files.wordpress.com/2015/06/fullprocess.png" alt="Full Process" width="660" height="305" /></a>
