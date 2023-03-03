#!/bin/bash

# https://docs.stardog.com/etl-data-into-stardog#installation

STARDOG_VERSION_NUMBER=8.2.1

# mkdir -p nifi-lib
# cd nifi-lib
# wget http://downloads.stardog.com/extras/stardog-extras-$STARDOG_VERSION_NUMBER.zip

mkdir drivers
cd drivers

wget https://jdbc.postgresql.org/download/postgresql-42.5.3.jar

wget https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.1.2/mariadb-java-client-3.1.2.jar

# wget https://jdbc.postgresql.org/download/postgresql-42.2.5.jar