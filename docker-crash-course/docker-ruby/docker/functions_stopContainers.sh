#!/bin/bash

function stopContainer() {
    container=$1
    [ "$container" = "" ] && echo "Please specific what container do you wanna stop.  Or use <all> to stop all development containers, or <allContainers> to stop it ALL." && exit 1
    case "$container" in
        all)
            stopDevContainers
            ;;
        allContainers)
            stopAllContainers
            ;;
        *)
            if [ "$(isActiveContainer $container)" = "True" ]; then
                echo "[INFO] Stopping container <$container>"
                docker rm -v $container -f
            else
                activeContainers=$(getActiveContainers)
                echo "[ERROR] <$container> Is not a running container to be stopped. Running containers are: $activeContainers"
                exit 1
            fi
            ;;
    esac
}