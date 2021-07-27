#!/bin/bash
docker-compose build
docker run --env-file fat_container.env  -p 18080:80 -it fat_container_appsmith:latest /bin/bash
