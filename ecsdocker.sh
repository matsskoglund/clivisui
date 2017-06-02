#!/bin/bash
eval $(aws ecr get-login --region eu-west-1)
#docker build -t matsskoglund/clivisui .
docker build -t mskvb0/clivisui .

#docker tag matsskoglund/clivisui:latest 766470935727.dkr.ecr.eu-west-1.amazonaws.com/matsskoglund/clivisui:latest
docker tag mskvb0/clivisui:latest 644569545355.dkr.ecr.eu-west-1.amazonaws.com/mskvb0/clivisui:latest
docker tag mskvb0/clivisui:latest 644569545355.dkr.ecr.eu-west-1.amazonaws.com/mskvb0/clivisui:$BUILD_BUILDID

#docker push 766470935727.dkr.ecr.eu-west-1.amazonaws.com/matsskoglund/clivisui:latest
docker push 644569545355.dkr.ecr.eu-west-1.amazonaws.com/mskvb0/clivisui:latest
docker push 644569545355.dkr.ecr.eu-west-1.amazonaws.com/mskvb0/clivisui:$BUILD_BUILDID

