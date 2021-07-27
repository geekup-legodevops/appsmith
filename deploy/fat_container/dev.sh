#!/bin/bash
docker-compose build
docker run --env-file fat_container.env -it fat_container_appsmith:latest /bin/bash
