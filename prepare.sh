#!/bin/bash

mkdir drivers
cd drivers

# Download JDBC drivers for PostgreSQL, MariaDB and MySQL
wget -N https://jdbc.postgresql.org/download/postgresql-42.5.3.jar
wget -N https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.1.2/mariadb-java-client-3.1.2.jar
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.33.zip

unzip mysql-connector-j-*.zip
mv mysql-connector-j-*/mysql-connector-j-*.jar .
rm -rf mysql-connector-j-*.zip mysql-connector-j-*/

echo "✅ JDBC drivers downloaded in the drivers/ folder"
