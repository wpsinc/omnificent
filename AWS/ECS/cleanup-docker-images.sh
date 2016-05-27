#!/bin/bash

# Shell script to remove unused Docker images.
# @author: "Austin Maddox" <amaddox@wps-inc.com>
#
# By default, Docker caches images indefinitely. Cached images can be useful to reduce the time needed to launch new tasks: if the image is cached, the container can be started from the cache. If you have a lot of images that are rarely used, as is common in CI or development environments, then cleaning these out is a good idea.

if [ $# -lt 2 ]; then
    echo "Usage: cleanup-docker-images.sh <region> <auto-scaling-group> <organization> <repository> <revision>"
    echo "The first two arguments are required: region, auto-scaling-group"
    exit 0
fi

REGION=$1
AUTO_SCALING_GROUP_NAME=$2
ORGANIZATION=$3
REPOSITORY=$4
REVISION=$5

for i in `aws autoscaling describe-auto-scaling-groups --region=${REGION} --auto-scaling-group-name ${AUTO_SCALING_GROUP_NAME} | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1 | sed -e 's/"//g'`
do
    # Remove all unused Docker images.
    aws ssm send-command --region=${REGION} --instance-ids $i --document-name="AWS-RunShellScript" --comment="${ORGANIZATION}/${REPOSITORY}:${REVISION}" --parameters commands="docker images -q | xargs --no-run-if-empty docker rmi"
done
