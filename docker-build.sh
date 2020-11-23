#!/bin/sh
set -e

env UID=$(id -u)\
    docker-compose build