#!/bin/bash

# Shell script to deploy an application using the ECS API via the AWS CLI.
# @author: "Austin Maddox" <amaddox@wps-inc.com>

if [ $# -lt 7 ]; then
    echo "Usage: deploy.sh <revision> <cluster> <region> <service> <task-definition-file> <task-definition> <family>"
    exit 0
fi

REVISION=$1
CLUSTER=$2
REGION=$3
SERVICE=$4
TASK_DEFINITION_FILE=$5
TASK_DEFINITION=$6
FAMILY=$7

TASK_DEFINITION_FILE_VERSIONED=${TASK_DEFINITION}-${REVISION}.json

# Replace %REVISION% with the build number in the task definition JSON file.
echo "Creating a versioned task definition JSON file..."
sed -e "s;%REVISION%;${REVISION};g" ${TASK_DEFINITION_FILE} > ${TASK_DEFINITION_FILE_VERSIONED}
echo "Finished creating the ${TASK_DEFINITION_FILE_VERSIONED} file."

# Create a new task definition for this build.
echo "Registering the new task definition..."
aws ecs register-task-definition --family ${FAMILY} --region=${REGION} --cli-input-json file://${TASK_DEFINITION_FILE_VERSIONED}
echo "Finished registering the new task definition."

# Set the task revision variable.
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${TASK_DEFINITION} --region=${REGION} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`

# Set the desired count to whatever it was before this script was run.
DESIRED_COUNT=`aws ecs describe-services --cluster ${CLUSTER} --services ${SERVICE} --region=${REGION} | egrep -m 1 "desiredCount" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
if [ "${DESIRED_COUNT}" = "" ] || [ -z "${DESIRED_COUNT}" ] || [ "${DESIRED_COUNT}" = "0" ]; then
    DESIRED_COUNT="1"
fi

# Update the service with the new task definition and desired count.
echo "Updating the ECS service..."
aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE} --task-definition ${TASK_DEFINITION}:${TASK_REVISION} --desired-count ${DESIRED_COUNT} --region=${REGION}
echo "Finished updating the ECS service."
