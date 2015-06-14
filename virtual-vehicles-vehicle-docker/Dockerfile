FROM java:8u45-jdk
COPY ./virtual-vehicles-vehicle-docker/artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8581
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Vehicle-1.0-SNAPSHOT.jar", "prod", "com.example.vehicle.Main"]
CMD [""]