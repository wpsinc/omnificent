#!/bin/bash
echo ECS_CLUSTER=cluster-dev >> /etc/ecs/ecs.config
cd /tmp
cat /etc/ecs/ecs.config | grep -v 'ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION' > /tmp/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m" >> /tmp/ecs.config
mv -f /tmp/ecs.config /etc/ecs/
curl -O https://bootstrap.pypa.io/get-pip.py
python27 get-pip.py
/usr/local/bin/pip install --upgrade awscli
su - ec2-user -c "aws s3 cp s3://wps-settings/cluster-dev /home/ec2-user/wps-settings/cluster-dev --recursive"
curl https://amazon-ssm-us-west-2.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm
su - ec2-user -c "aws ec2 associate-address --region=us-west-2 --instance-id `curl http://169.254.169.254/latest/meta-data/instance-id` --allocation-id eipalloc-e031d6dd"
