#http://stackoverflow.com/a/26878915/580268

FROM mongo:latest
RUN echo "smallfiles = true" >> /etc/mongod.conf
CMD ["mongod", "--config", "/etc/mongod.conf"]
