#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f0f6e9645d60d668"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z071623232QZDBSPG8GZL"
DOMAIN_NAME="vinnu.site"


for instance in ${INSTANCES[@]}
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0f0f6e9645d60d668  --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=test}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontemd" ]
    then
       IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
       IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"

   aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch '
   {
        "Comment": "Creating or Updating a record set for $instance"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "$instance.$DOMAIN_NAME"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "$IP"
            }]
 
        }
done