# Virtual-Vehicles Maintenance microservice Dockerfile

FROM java:8u45-jdk

MAINTAINER Gary A. Stafford <garystafford@rochester.rr.com>

ENV REFRESHED_AT 2015-07-20

#RUN apt-get -y update && \
#apt-get -y upgrade && \
#apt-get -y dist-upgrade && \
#apt-get -y clean && \
#apt-get -y autoclean && \
#apt-get -y autoremove

#RUN touch /var/log/virtual-maintenance.log && \
#ln -sf /dev/stdout /var/log/virtual-maintenance.log

COPY ./artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles

ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Maintenance-1.0-SNAPSHOT.jar", "test", "com.example.maintenance.Main"]
CMD [""]