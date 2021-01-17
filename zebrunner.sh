#!/bin/bash

  setup() {

    cp .env.original .env
    if [[ $ZBR_MINIO_ENABLED -eq 0 ]]; then
      # use case with AWS S3
      sed -i "s#S3_REGION=us-east-1#S3_REGION=${ZBR_STORAGE_REGION}#g" .env
      sed -i "s#S3_ENDPOINT=http://minio:9000#S3_ENDPOINT=${ZBR_STORAGE_ENDPOINT_PROTOCOL}://${ZBR_STORAGE_ENDPOINT_HOST}#g" .env
      sed -i "s#S3_BUCKET=zebrunner#S3_BUCKET=${ZBR_STORAGE_BUCKET}#g" .env
      sed -i "s#S3_ACCESS_KEY_ID=zebrunner#S3_ACCESS_KEY_ID=${ZBR_STORAGE_ACCESS_KEY}#g" .env
      sed -i "s#S3_SECRET=J33dNyeTDj#S3_SECRET=${ZBR_STORAGE_SECRET_KEY}#g" .env

      if [[ ! -z $ZBR_STORAGE_TENANT ]]; then
        sed -i "s#/artifacts#${ZBR_STORAGE_TENANT}/artifacts#g" .env
      fi
    fi

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

    curl -L -o bin/cm $LATEST_BINARY_URL
    chmod +x bin/cm

    VERSION=`bin/cm version`

    say "
    SUCCESSFULLY DOWNLOADED!

    $VERSION
    "

    bin/cm selenoid update --vnc --config-dir "${BASEDIR}" $*

    docker rm -f selenoid
  }

  shutdown() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    docker-compose --env-file .env -f docker-compose.yml down -v

    rm -f browsers.json
    rm -f .env
  }

  start() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    # create infra network only if not exist
    docker network inspect infra >/dev/null 2>&1 || docker network create infra

    if [[ ! -f .env ]]; then
      cp .env.original .env
    fi

    docker-compose --env-file .env -f docker-compose.yml up -d
  }

  stop() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    docker-compose --env-file .env -f docker-compose.yml stop
  }

  down() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    docker-compose --env-file .env -f docker-compose.yml down
  }

  backup() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    cp .env .env.bak
    cp browsers.json browsers.json.bak
  }

  restore() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    stop
    cp .env.bak .env
    cp browsers.json.bak browsers.json
    cd ${BASEDIR}
    down
  }

  version() {
    if [[ -f .disabled ]]; then
      exit 0
    fi

    source .env
    echo "selenoid: ${TAG_SELENOID}"
  }

  echo_warning() {
    echo "
      WARNING! $1"
  }

  echo_telegram() {
    echo "
      For more help join telegram channel: https://t.me/zebrunner
      "
  }

  echo_help() {
    echo "
      Usage: ./zebrunner.sh [option]
      Flags:
          --help | -h    Print help
      Arguments:
          setup          Download two latest versions of chrome, firefox and opera browsers
      	  start          Start container
      	  stop           Stop and keep container
      	  restart        Restart container
      	  down           Stop and remove container
      	  shutdown       Stop and remove container, clear volumes
      	  backup         Backup container
      	  restore        Restore container
      	  version        Version of container"
      echo_telegram
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
    version)
        version
        ;;
    *)
        echo "Invalid option detected: $1"
        echo_help
        exit 1
        ;;
esac

