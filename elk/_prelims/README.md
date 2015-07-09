Must move .conf files to shared volume on docker-machine vm

scp:
```bash
docker-machine scp [machine:][path] [machine:][path]
docker-machine ssh test
docker-machine ssh test pwd # /home/docker
```

docker-compose.yaml:
```bash
  volumes:
    - "/home/docker/logstash:/etc/logstash"
```

For example, from my machine:
```bash
sudo mkdir /etc/logstash
sudo rm -rf /etc/logstash/*
sudo cp elk/*.conf /etc/logstash/

local=/etc/logstash && \
remote=$(docker-machine ssh test pwd) && \
docker-machine scp -r ${local} test:${remote}
```

Change ownership of directory:
```bash
docker-machine ssh test sudo chown docker /home/docker/logstash/
```

Restart container:
```bash
docker restart jenkins_elk_1
```

Check logs:
```bash
docker exec -it jenkins_elk_1 cat /var/log/logstash/stdout.log
docker exec -it jenkins_elk_1 cat /var/log/elasticsearch/logstash.log
```

Reference:  
 * https://docs.docker.com/machine/#scp
 * http://stackoverflow.com/questions/30040708/how-to-mount-local-volumens-in-docker-machine
 * http://logstash.net/docs/1.3.3/tutorials/getting-started-simple
