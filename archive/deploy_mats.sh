#!/bin/bash
aws ecs register-task-definition --cli-input-json file://task.json --profile mats

aws ecs update-service --cluster Clivisui-cluster --service Clivisui-elb-service --task-definition Clivisui --profile mats
