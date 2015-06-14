FROM java:8u45-jdk
COPY ./artifacts /usr/share/java/virtual-vehicles
WORKDIR /usr/share/java/virtual-vehicles
EXPOSE 8081
ENTRYPOINT ["java", "-classpath", ".:config:", "-jar", "Authentication-1.0-SNAPSHOT.jar", "prod", "com.example.authentication.Main"]
CMD [""]