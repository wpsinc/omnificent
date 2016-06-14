#!/bin/bash

# This script is the "User data" or sometimes referred to as the "Cloud init script" that is run during bootup of a new EC2 server. This script is copied into the user data upon creating a launch configuration for auto scaling.
#
# @author: "Austin Maddox" <amaddox@wps-inc.com>
#
# You can specify user data to configure an instance or run a configuration script during launch. If you launch more than one instance at a time, the user data is available to all the instances in that reservation.

# Specify which ECS cluster to associate this instance with.
echo ECS_CLUSTER=web-production-cluster >> /etc/ecs/ecs.config

cd /tmp

# Adjust the frequency of the task that cleans up stopped containers. (Default: 3h)
cat /etc/ecs/ecs.config | grep -v 'ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION' > /tmp/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m" >> /tmp/ecs.config
mv -f /tmp/ecs.config /etc/ecs/

# Download pip.
curl -O https://bootstrap.pypa.io/get-pip.py

# Install pip.
python27 get-pip.py

# Install the AWS CLI.
/usr/local/bin/pip install --upgrade awscli

# Grab all configuration files from S3.
su - ec2-user -c "aws s3 cp s3://web-settings/production /home/ec2-user/web-settings/production --recursive"

# Install the Simple Systems Manager (SSM) for the Amazon EC2 Run Command to manage EC2 instances remotely.
curl https://amazon-ssm-us-west-2.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm

# Pull the latest Spotify garbage collection image so we can run it on deployment later.
docker pull spotify/docker-gc:latest
