#!/bin/bash

  setup() {
    docker network inspect infra >/dev/null 2>&1 || docker network create infra

    echo downloading latest chrome/firefox/opera browser images

    set -e +o pipefail

    say() {
      echo -e "$1"
    }

    platform="$(uname -s)"
    case "${platform}" in
        Linux*)     OS_TYPE=linux;;
        Darwin*)    OS_TYPE=darwin;;
        *)          say "This script don't know how to deal with ${platform} os type!"; exit 1
    esac

    LATEST_BINARY_URL=`curl -s https://api.github.com/repos/aerokube/cm/releases/latest | grep "browser_download_url" | grep ${OS_TYPE} | cut -d : -f 2,3 | tr -d \"`

    curl -L -o ${BASEDIR}/bin/cm $LATEST_BINARY_URL
    chmod +x ${BASEDIR}/bin/cm

    VERSION=`${BASEDIR}/bin/cm version`

    say "
    SUCCESSFULLY DOWNLOADED!

    $VERSION
    "

    ${BASEDIR}/bin/cm selenoid update --vnc --config-dir "${BASEDIR}" $*

    docker rm -f selenoid
  }

  start() {
    # create infra network only if not exist
    docker network inspect infra >/dev/null 2>&1 || docker network create infra

    if [[ ! -f ${BASEDIR}/.disabled ]]; then
      docker-compose --env-file ${BASEDIR}/.env -f ${BASEDIR}/docker-compose.yml up -d
    fi
  }

  stop() {
    if [[ ! -f ${BASEDIR}/.disabled ]]; then
      docker-compose --env-file ${BASEDIR}/.env -f ${BASEDIR}/docker-compose.yml stop
    fi
  }

  down() {
    if [[ ! -f ${BASEDIR}/.disabled ]]; then
      docker-compose --env-file ${BASEDIR}/.env -f ${BASEDIR}/docker-compose.yml down
    fi
  }

  shutdown() {
    if [[ ! -f ${BASEDIR}/.disabled ]]; then
      docker-compose --env-file ${BASEDIR}/.env -f ${BASEDIR}/docker-compose.yml down -v
    fi

    rm -rf ${BASEDIR}/video/*.mp4
    rm ${BASEDIR}/browsers.json
  }

  backup() {
    cp ${BASEDIR}/browsers.json ${BASEDIR}/browsers.json.bak
  }

  restore() {
    mv ${BASEDIR}/browsers.json.bak ${BASEDIR}/browsers.json
  }

  echo_help() {
    echo "
      Usage: ./zebrunner.sh [option]
      Flags:
          --help | -h    Print help
      Arguments:
          start          Start container
          stop           Stop and keep container
          restart        Restart container
          down           Stop and remove container
          shutdown       Stop and remove container, clear volumes
          backup         Backup container
          restore        Restore container
      For more help join telegram channel https://t.me/qps_infra"
      exit 0
  }


BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${BASEDIR}

case "$1" in
    setup)
        docker network inspect infra >/dev/null 2>&1 || docker network create infra
        setup
        ;;
    start)
	start
        ;;
    stop)
        stop
        ;;
    restart)
        down
        start
        ;;
    down)
        down
        ;;
    shutdown)
        shutdown
        ;;
    backup)
        backup
        ;;
    restore)
        restore
        ;;
    *)
        echo "Invalid option detected: $1"
        echo_help
        exit 1
        ;;
esac

