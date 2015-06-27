# Virtual-Vehicles Vehicle microservice Dockerfile

FROM java:8u45-jdk
MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2015-06-23

RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y dist-upgrade && \
apt-get -y clean && \
apt-get -y autoclean && \
apt-get -y autoremove

COPY ./artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

#EXPOSE 8581

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Vehicle-1.0-SNAPSHOT.jar", "prod", "com.example.vehicle.Main"]
CMD [""]