# Virtual-Vehicles Vehicle microservice Dockerfile

FROM java:8u45-jdk

MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2015-08-09

COPY ./build-artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Vehicle-1.125.jar", "test", "com.example.vehicle.Main"]
CMD [""]