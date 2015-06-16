# Virtual-Vehicles Authentication microservice Dockerfile

FROM java:8u45-jdk
MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2015-06-15

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
apt-get -y update && \
apt-get -y upgrade && \
apt-get -y dist-upgrade && \
apt-get -y clean && \
apt-get -y autoclean && \
apt-get -y autoremove

COPY ./artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

EXPOSE 8587

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Authentication-1.0-SNAPSHOT.jar", "prod", "com.example.authentication.Main"]
CMD [""]