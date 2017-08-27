#!/bin/bash

# This script starts hakchi using docker-compose

docker-compose run -e DISPLAY=$(hostname):0 hakchi