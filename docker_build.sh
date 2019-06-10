#!/bin/bash
export USER_NAME=serboox

for service in ui post comment; do
    docker images | grep ${USER_NAME}/${service} | awk '{print $3}' | xargs docker rmi -f;
done

for i in ui post-py comment; do
    cd src/$i;
    bash docker_build.sh;
    cd -;
done

docker login --username=$USER_NAME
for service in ui post comment; do
    docker push ${USER_NAME}/${service};
done
