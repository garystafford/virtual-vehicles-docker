FROM java:8u45-jdk
COPY ./virtual-vehicles-valet-docker/artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8585
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Valet-1.0-SNAPSHOT.jar", "prod", "com.example.valet.Main"]
CMD [""]