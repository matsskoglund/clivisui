[
  {
    "name": "clivisui",
    "image": "644569545355.dkr.ecr.eu-west-1.amazonaws.com/mskvb0/clivisui:${image_id}",
    "cpu": 10,
    "memory": 300,
    "links": [],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "entryPoint": [],
    "command": [],
    "environment": [],
    "mountPoints": [],
    "volumesFrom": [],
    "environment": [
      {
        "name": "BUILD_VERSION",
        "value": "${image_id}"
      },
      {
        "name": "SERVICE_URL",
        "value": "${env_service_url}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log-group}",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "clivisui-log-"
      }
    }
  }
]