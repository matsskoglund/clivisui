#!/bin/bash
#aws ecs register-task-definition --cli-input-json file://task.json --profile mats
aws ecs register-task-definition --cli-input-json file://mskvb0-task.json --profile mskvb0
#aws ecs register-task-definition --cli-input-json file://mskvb0-clivisui-task-def.json --profile mskvb0

#aws ecs update-service --cluster Clivisui-cluster --service Clivisui-elb-service --task-definition Clivisui --profile mats
aws ecs update-service --cluster mskvb0-clivisui-cluster --service mskvb0-Clivisui-service --task-definition mskvb0-Clivisui --profile mskvb0
#aws ecs update-service --cluster mskvb0-clivisui-cluster-test --service mskvb0-Clivisui-service-test --task-definition mskvb0-clivisui-test --profile mskvb0