#!/bin/bash

#Setup arguments
cmd=$1
db_username = $2
db_password = $3

#Check to see if a docker daemon is running, if not then start one
systemctl status docker || systemctl start docker

#creates container jrvs-psql if one does not already exists
if [ $1 == "create" ];then
  if [ $(docker container ls -a -f name=jrvs-psql | wc -l) -eq 2 ];then
    echo "jrvs-psql container already created"
    exit 1
  fi

  if [ "$#" != 3 ];then
    echo "did not enter correct amount of arguements"
    exit 1
  fi
  docker volume create pgdata
  docker run --name jrvs-psql -e POSTGRES_PASSWORD=${db_password} -e POSTGRES_USER=${db_username} -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres
  exit $?
fi

#error to check if jrvs-psql container exists
if [ $(docker container ls -a -f name=jrvs-psql | wc -l) -eq 1 ];then
  echo "jrvs-psql does not exist"
  exit 1
fi

#start jrvs-psql container
if [ "$1" == "start" ];then
  docker container start jrvs-psql
  exit $?
fi

#stop jrvs-psql container
if [ "$1" == "stop" ];then
  docker container stop jrvs-psql
  exit $?
fi

#error to check if command exists
if [ "$1" != "create" || "$1" != "start" || "$1" != "stop" ];then
  echo "invalid command"
  exit 1
fi

exit 0
