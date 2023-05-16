#!/bin/bash

ssh ids2 'cd /data/deploy-services/deploy-stardog ; git pull ; docker-compose down ; docker-compose up -d'
