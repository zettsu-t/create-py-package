#!/bin/bash
# docker build my_notebook -t my_notebook --build-arg $(< password_digest.txt)
docker-compose build --build-arg $(< password_digest.txt)
