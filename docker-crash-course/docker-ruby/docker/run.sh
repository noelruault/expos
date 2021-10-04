#!/bin/bash
# This is the main entry point for the DBSS docker script. In this file are defined
# common funtions and the main __init__() entry point.
# This script is used for development pourposes.

function createImages() {
    echo "[INFO] Creating images..."
    # docker pull mariadb
    # docker pull node:8

    docker build . -t qvantel/masmovil-base
    createNetworks
}

function createNetworks() {
    echo "[INFO] Creating networks ..."
    docker network create -d bridge net_control
}

function getActiveContainers() {
    active_containers=$(docker ps -a | grep -v NAMES | tr -s " " | rev | cut -d " " -f 1 | rev)
    echo $active_containers
}

function showUsage() {
    echo "This utility is to easely manage BSSD docker containers for development."
    echo "To properly use it you first need to have all necessary docker images; to get them all just execute <run.sh create>."
    echo "Finally in order to get up&running any other container for development porpouses you must execute <run.sh start [container-name]>. With an empty container name you will get a list of valid containers names."
    echo ""
    echo "run.sh usage: [create] | [start] | [stop] | [restart]"
    echo "    create: Create images. Download and configure all docker images."
    echo "    start [container-name]: Create and launch containers. If not provided, a list with valid containers names is displayed."
    echo "    stop [container-name]: Stop and delete containers. If not provided, a list with valid containers names is displayed."
}

function __init__(){
    VALID_CONTAINERS=$(cat ./docker/functions_containers.sh | grep "function startContainer_" | cut -d " " -f 2 | cut -d "_" -f 2 | tr -d "()")
    case "$1" in
    create)
        createImages
        ;;
    start)
        shift
        case "$1" in
            *)
                container=$1
                shift
                # Check if the container param is a valid container name
                echo $VALID_CONTAINERS | tr " " "\n" | grep -w $container > /dev/null 2>&1
                if [ "$?" = "0" ]; then
                    eval 'startContainer_'$container $@
                else
                    echo "Valid containers names to start are: "$VALID_CONTAINERS
                    exit 1
                fi
                ;;
            esac
            ;;
        stop)
            shift
            stopContainer $@
            ;;
        restart)
            $0 stop $2
            $0 start $2
            ;;
        *)
            showUsage
            exit 1
            ;;
    esac
}

# Set the folder to project, no matter from where the script was called.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPT_DIR/..
source ./docker/functions_containers.sh
source ./docker/functions_stopContainers.sh
__init__ "$@"
