#!/bin/bash
# Functions file with all methods to create containers.
# To add a new container to the list, just create a method with the name "startContainer_XXX"
# where XXX will match the container's name, and this name must be lowercase.
# Following this pattern the container will be automatically included at the script methods.
# Each method will receive any params typed at console, for example for the command:
#    ./docker/run.sh start bash XXXX
# The method startContainer_bash will be called with XXXX as param $1

source ./docker/functions_mariadbContainer.sh
function startContainer_mariadb() {
    startMariaDBContainer
}

function startContainer_newton() {
    app_name="newton"
    container_path="/mnt/$app_name"
    echo "[INFO] Starting Newton ..."
    # docker run -it -v $(pwd):/mnt--net=net_control -p 6000:3000 --name newton qvantel/masmovil-base /bin/bash
    docker run -p 6000:3000 --name newton --rm -itd -v $(pwd):/mnt --net=net_control qvantel/masmovil-base bash
    docker container exec -it newton sh -c "/mnt/docker/scripts/create_db.sh"
    docker container exec -it newton sh -c "cd $container_path && bundle exec rails server -b 0.0.0.0"
}

######################################

function startContainer_bash() {
    container=$1
    echo "[INFO] Opening a bash console at container <$container> ..."
    active_containers=$(getActiveContainers)
    echo $active_containers | tr " " "\n" | grep -w $container > /dev/null 2>&1
    [ "$?" != "0" ] && echo "[ERROR] <$container> is not a valid container. Valid running containers to open a bash are:" $active_containers && exit 1
    docker container exec -it $container /bin/bash
}
