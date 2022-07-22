# Apache NiFi for Stardog ETL

A docker image and docker-compose deployment for Apache NiFi with the Stardog extensions pre-installed.

### Deploy locally

Build and start the docker container locally:

```bash
docker-compose up
```

Access the UI on https://localhost:8080/nifi

### Notes

Password must be more than 12 characters.

Get the generated login/password if not defined:

```bash
docker-compose exec nifi-stardog bash -c "grep Generated logs/nifi-app*log"
```

Change the password in the running container:

```bash
docker-compose exec nifi-stardog bash -c "./bin/nifi.sh set-single-user-credentials admin password"
```

### Links

* Stardog docs for an ETL example: https://docs.stardog.com/etl-data-into-stardog
* Blog article: https://www.stardog.com/labs/blog/stardog-data-flow-automation-with-nifi/
* Nifi cluster: https://medium.com/geekculture/host-a-fully-persisted-apache-nifi-service-with-docker-ffaa6a5f54a3

