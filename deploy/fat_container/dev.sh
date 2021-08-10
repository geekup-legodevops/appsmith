#!/bin/bash
docker-compose build
docker run --env-file fat_container.env  -p 18080:80 -it f_sm:latest /bin/bash
