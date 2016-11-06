# Virtual-Vehicles Authentication microservice Dockerfile

FROM java:8u102-jdk

MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2016-11-06

COPY ./build-artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "{{ jar_file }}", "test", "com.example.authentication.Main"]
CMD [""]
