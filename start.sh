#!/bin/bash
printf "\nChecking if repository is cloned"
if test -d "stock-swarm"; then
        printf "\nRepository exists\n"
        cd stock-swarm
else
        printf "\nRepository does not exist...\n"
        printf "\nCloning stock exchange repository\n"
        if git clone https://github.com/raphau-soft/stock-swarm.git; then
                cd stock-swarm
                printf "\nCloning finished\n"
        else
                printf "\nCloning error\n"
                exit 0
        fi
fi
printf "\nUpdating repository...\n"
if git pull; then
        printf "\nRepository updated\n"
else
        printf "\nRepository update error\n"
fi
printf "\nChecking if docker swarm is active\n"
case "$(docker info --format '{{.Swarm.LocalNodeState}}')" in
        inactive)
                printf "\nNode is not in swarm mode...\n"
                printf "\nTrying to initialize swam mode...\n"
                if docker swarm init; then
                        printf "\nSwarm initialized!\n"
                else
                        printf "\nSwarm initialize error\n"
                        exit 0
                fi
esac
printf "\nCreating docker network for stock...\n"
if docker network create --scope swarm -d overlay app-network; then
        printf "\nNetwork created successfully\n"
else
        printf "\nNetwork exists\n"
fi
printf "\n Stopping working services"
docker stack rm stock-stack
printf "\nTrying to run stock exchange stack...\n"
if docker stack deploy --compose-file docker-compose.yml stock-stack; then
        printf "\nStack initialized successfully\n"
else
        printf "\nStack initialization error\n"
        exit 0
fi
printf "\nScaling stock...\n"
if docker service scale stock-stack_stock-app=5; then
        printf "\nStock scaled successfully\n"
else
        printf "\nStock scale error\n"
fi
