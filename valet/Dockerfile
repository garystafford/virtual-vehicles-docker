# Virtual-Vehicles Valet microservice Dockerfile

FROM java:8u45-jdk

MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2015-08-09

COPY ./build-artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Valet-1.124.jar", "test", "com.example.valet.Main"]
CMD [""]