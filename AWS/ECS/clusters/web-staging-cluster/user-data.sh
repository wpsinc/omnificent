#!/bin/bash

# This script is the "User data" or sometimes referred to as the "Cloud init script" that is run during bootup of a new EC2 server. This script is copied into the user data upon creating a launch configuration for auto scaling.
#
# @author: "Austin Maddox" <amaddox@wps-inc.com>
#
# You can specify user data to configure an instance or run a configuration script during launch. If you launch more than one instance at a time, the user data is available to all the instances in that reservation.

# Specify which ECS cluster to associate this instance with.
echo ECS_CLUSTER=web-staging-cluster >> /etc/ecs/ecs.config

# Download pip.
curl -O https://bootstrap.pypa.io/get-pip.py

# Install pip.
python27 get-pip.py

# Install the AWS CLI.
/usr/local/bin/pip install --upgrade awscli

# Grab all configuration files from S3.
su - ec2-user -c "aws s3 cp s3://web-settings/staging /home/ec2-user/web-settings/staging --recursive"
