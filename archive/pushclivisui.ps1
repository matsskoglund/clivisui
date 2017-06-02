$login = aws ecr get-login --region eu-west-1
Invoke-Expression $login
docker build -t matsskoglund/clivisui .
docker tag matsskoglund/clivisui:latest 766470935727.dkr.ecr.eu-west-1.amazonaws.com/matsskoglund/clivisui:latest
docker push 766470935727.dkr.ecr.eu-west-1.amazonaws.com/matsskoglund/clivisui:latest
