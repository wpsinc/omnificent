#!/bin/bash

# Shell script to remove unused Docker images.
# @author: "Austin Maddox" <amaddox@wps-inc.com>
#
# By default, Docker caches images indefinitely. Cached images can be useful to reduce the time needed to launch new tasks: if the image is cached, the container can be started from the cache. If you have a lot of images that are rarely used, as is common in CI or development environments, then cleaning these out is a good idea.

if [ $# -lt 2 ]; then
    echo "Usage: cleanup-docker-images.sh <region> <auto-scaling-group-name> <username> <organization> <repository> <branch> <revision>"
    echo "The first two arguments are required: region, auto-scaling-group"
    exit 0
fi

REGION=$1
AUTO_SCALING_GROUP_NAME=$2
USERNAME=$3
ORGANIZATION=$4
REPOSITORY=$5
BRANCH=$6
REVISION=$7

INSTANCES=($(aws autoscaling describe-auto-scaling-groups --region=${REGION} --auto-scaling-group-name "${AUTO_SCALING_GROUP_NAME}" | grep InstanceId | cut -d'"' -f4 | tr '\n' ' '))

for INSTANCE_ID in ${INSTANCES[*]}
do
    aws ssm send-command --region=${REGION} --instance-ids ${INSTANCE_ID} --document-name="AWS-RunShellScript" --comment="${USERNAME} triggered ${ORGANIZATION}/${REPOSITORY} > ${BRANCH} > build ${REVISION}" --parameters commands="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock spotify/docker-gc"
done
