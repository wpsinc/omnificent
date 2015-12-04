#!/bin/bash

# Grant or revoke security group access to a whole entire region range of IP addresses.
#
# @author: "Austin Maddox" <amaddox@wps-inc.com>
#
# This script absolutely has a high likelihood of breaking in the future. AWS could change their IP address ranges at any time.
# It would probably be best to build this from the JSON file that AWS publishes and updates periodically instead of hard-coding them here.
# Read more: http://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html

if [ $# -lt 4 ]; then
    echo "Usage: ./security-group-ingress.sh (authorize|revoke) group-id protocol port region"
    echo "Example: ./security-group-ingress.sh authorize sg-01234567 tcp 3306 us-west-2"
    exit 0
fi

ACTION=$1
GROUP_ID=$2
PROTOCOL=$3
PORT=$4
REGION=$5

# Build array of IP addresses with CIDR notations.
US_EAST_1=(
    '23.20.0.0/14'
    '50.16.0.0/15'
    '50.19.0.0/16'
    '52.0.0.0/15'
    '52.2.0.0/15'
    '52.4.0.0/14'
    '52.20.0.0/14'
    '52.95.245.0/24'
    '52.95.255.80/28'
    '54.80.0.0/13'
    '54.88.0.0/14'
    '54.92.128.0/17'
    '54.144.0.0/14'
    '54.152.0.0/16'
    '54.156.0.0/14'
    '54.160.0.0/13'
    '54.172.0.0/15'
    '54.174.0.0/15'
    '54.196.0.0/15'
    '54.198.0.0/16'
    '54.204.0.0/15'
    '54.208.0.0/15'
    '54.210.0.0/15'
    '54.221.0.0/16'
    '54.224.0.0/15'
    '54.226.0.0/15'
    '54.234.0.0/15'
    '54.236.0.0/15'
    '54.242.0.0/15'
    '67.202.0.0/18'
    '72.44.32.0/19'
    '75.101.128.0/17'
    '107.20.0.0/14'
    '174.129.0.0/16'
    '184.72.64.0/18'
    '184.72.128.0/17'
    '184.73.0.0/16'
    '204.236.192.0/18'
    '216.182.224.0/20'
)

echo "Performing the specified action on the security group with ${#US_EAST_1[@]} us-east-1 IP Addresses..."

for ((i = 0; i < ${#US_EAST_1[@]}; i++)); do
    echo ${ACTION} ${US_EAST_1[$i]}
    aws ec2 ${ACTION}-security-group-ingress --group-id ${GROUP_ID} --protocol ${PROTOCOL} --port ${PORT} --region ${REGION} --cidr ${US_EAST_1[$i]}
done

echo "...Done."
