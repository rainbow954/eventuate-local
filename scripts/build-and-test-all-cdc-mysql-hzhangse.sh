#!/bin/bash
#设置网卡ech0的ip地址为docker_host
export DOCKER_HOST_IP=`ifconfig eth0 |awk -F '[ :]+' 'NR==2{print $4}'`
set -e

if [ -z "$DOCKER_COMPOSE" ]; then
    echo setting DOCKER_COMPOSE
    export DOCKER_COMPOSE="docker-compose -f docker-compose-mysql.yml -f docker-compose-cdc-mysql.yml"
else
    echo using existing DOCKER_COMPOSE = $DOCKER_COMPOSE
fi

export GRADLE_OPTIONS="-P excludeCdcLibs=true"

./gradlew $GRADLE_OPTIONS $* :eventuate-local-java-cdc-service:clean :eventuate-local-java-cdc-service:assemble -i

. ./scripts/set-env-mysql.sh

$DOCKER_COMPOSE stop
$DOCKER_COMPOSE rm --force -v

$DOCKER_COMPOSE build
$DOCKER_COMPOSE up -d mysql
$DOCKER_COMPOSE up -d


./gradlew $GRADLE_OPTIONS :eventuate-local-java-jdbc-tests:cleanTest -i

# wait for MySQL

echo waiting for MySQL

./scripts/wait-for-mysql.sh

./scripts/mysql-cli.sh  -i < eventuate-local-java-embedded-cdc/src/test/resources/cdc-test-schema.sql

./scripts/wait-for-services.sh $DOCKER_HOST_IP 8099

./gradlew $GRADLE_OPTIONS :eventuate-local-java-jdbc-tests:test -i

# Assert healthcheck good

echo testing restart MySQL restart scenario $(date)

$DOCKER_COMPOSE stop mysql

sleep 10

$DOCKER_COMPOSE start mysql

./scripts/wait-for-mysql.sh

./gradlew $GRADLE_OPTIONS :eventuate-local-java-jdbc-tests:cleanTest :eventuate-local-java-jdbc-tests:test -i

$DOCKER_COMPOSE stop
# $DOCKER_COMPOSE rm --force -v
