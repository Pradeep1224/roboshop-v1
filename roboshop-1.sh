#!/bin/bash

ami_id=ami-0055977a6e828a4f4
instance_type=t3.micro
domain_name=pradeepverse.online
hosted_zone_id=Z05446843FCZ0RI2Z1CIL

for instance in $@
do 
    echo "creating instance:$instance"
    instance_id=$(aws ec2 run-instances \
    --image-id $ami_id\
    --instance-type $instance_type \
    --security-groups "roboshop-common" "roboshop-$instance"\
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=robosho-$instance}]"\
   --query "Instances[0].InstanceId" \
    --output text)
    echo "$Instance Id : $instance_id"
done 
