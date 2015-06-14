FROM java:8u45-jdk
COPY ./virtual-vehicles-authentication-docker/artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8587
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Authentication-1.0-SNAPSHOT.jar", "prod", "com.example.authentication.Main"]
CMD [""]