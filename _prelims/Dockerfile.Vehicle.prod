FROM java:8u45-jdk
COPY ./artifacts/Vehicle/target /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8081
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Vehicle-1.0-SNAPSHOT.jar", "prod", "com.example.vehicle.Main"]
CMD [""]