# Virtual-Vehicles Maintenance microservice Dockerfile

FROM java:8u45-jdk
MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

RUN apt-get -y update && \
apt-get -y upgrade && \
apt-get -y dist-upgrade && \
apt-get -y clean && \
apt-get -y autoclean && \
apt-get -y autoremove

COPY ./virtual-vehicles-maintenance-docker/artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

EXPOSE 8583

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Maintenance-1.0-SNAPSHOT.jar", "prod", "com.example.maintenance.Main"]
CMD [""]