#!/bin/bash

# Shell script to remove unused Docker images.
#
# By default, Docker caches images indefinitely. Cached images can be useful to reduce the time needed to launch new tasks: if the image is cached, the container can be started from the cache. If you have a lot of images that are rarely used, as is common in CI or development environments, then cleaning these out is a good idea.

if [ $# -lt 2 ]; then
    echo "Usage: cleanup-docker-images.sh <region> <cluster> <username> <organization> <repository> <branch> <revision>"
    echo "The first two arguments are required: region, cluster"
    exit 0
fi

REGION=$1
CLUSTER=$2
USERNAME=$3
ORGANIZATION=$4
REPOSITORY=$5
BRANCH=$6
REVISION=$7

# Get instances based on the Auto Scaling Group Name.
#INSTANCES=($(aws autoscaling describe-auto-scaling-groups --region=${REGION} --auto-scaling-group-name "${AUTO_SCALING_GROUP_NAME}" | grep InstanceId | cut -d'"' -f4 | tr '\n' ' '))

# Get instance based on the ECS Cluster Name.
# Note: This command requires instances be tagged with `Cluster => name-of-cluster`.
# Utilizes `jq` command-line JSON processor. (https://stedolan.github.io/jq)
INSTANCES=($(aws ec2 describe-instances --region=${REGION} --filters "Name=tag:Cluster,Values=${CLUSTER}" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" | jq --raw-output .[]))

for INSTANCE_ID in ${INSTANCES[*]}
do
    aws ssm send-command --region=${REGION} --instance-ids ${INSTANCE_ID} --document-name="AWS-RunShellScript" --comment="${USERNAME} triggered ${ORGANIZATION}/${REPOSITORY} > ${BRANCH} > build ${REVISION}" --parameters commands="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock spotify/docker-gc"
done
