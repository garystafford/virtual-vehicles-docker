FROM java:8u45-jdk
COPY ./virtual-vehicles-maintenance-docker/artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8583
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Maintenance-1.0-SNAPSHOT.jar", "prod", "com.example.maintenance.Main"]
CMD [""]