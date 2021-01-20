#!/bin/bash

  setup() {

    if [[ $ZBR_INSTALLER -eq 0 ]]; then
      # load default interactive installer settings
      source backup/settings.env.original

      # setup executed outside of zebrunner community edition. need ask about S3 compatible storage credentials
      set_aws_storage_settings
    fi

    cp .env.original .env
    if [[ ! $ZBR_MINIO_ENABLED -eq 1 ]]; then
      # use case with AWS S3
      replace .env "S3_REGION=us-east-1" "S3_REGION=${ZBR_STORAGE_REGION}"
      replace .env "S3_ENDPOINT=http://minio:9000" "S3_ENDPOINT=${ZBR_STORAGE_ENDPOINT_PROTOCOL}://${ZBR_STORAGE_ENDPOINT_HOST}"
      replace .env "S3_BUCKET=zebrunner" "S3_BUCKET=${ZBR_STORAGE_BUCKET}"
      replace .env "S3_ACCESS_KEY_ID=zebrunner" "S3_ACCESS_KEY_ID=${ZBR_STORAGE_ACCESS_KEY}"
      replace .env "S3_SECRET=J33dNyeTDj" "S3_SECRET=${ZBR_STORAGE_SECRET_KEY}"

      if [[ ! -z $ZBR_STORAGE_TENANT ]]; then
        replace .env "/artifacts" "${ZBR_STORAGE_TENANT}/artifacts"
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

  # https://github.com/zebrunner/zebrunner/issues/384 investigate possibility to make sub-components configurable independently
  # https://github.com/zebrunner/selenoid/issues/16 investigate possibility to make selenoid auto-configurable
  # IMPORTANT! copy of this method exists in root zebrunner.sh and maybe will be added to reporting/zebrunner.sh
  set_aws_storage_settings() {
    ## AWS S3 storage
    local is_confirmed=0
    #TODO: provide a link to documentation howto create valid S3 bucket
    echo
    echo "AWS S3 storage"
    while [[ $is_confirmed -eq 0 ]]; do
      read -p "Region [$ZBR_STORAGE_REGION]: " local_region
      if [[ ! -z $local_region ]]; then
        ZBR_STORAGE_REGION=$local_region
      fi

      ZBR_STORAGE_ENDPOINT_PROTOCOL="https"
      ZBR_STORAGE_ENDPOINT_HOST="s3.${ZBR_STORAGE_REGION}.amazonaws.com:443"

      read -p "Bucket [$ZBR_STORAGE_BUCKET]: " local_bucket
      if [[ ! -z $local_bucket ]]; then
        ZBR_STORAGE_BUCKET=$local_bucket
      fi

      read -p "Access key [$ZBR_STORAGE_ACCESS_KEY]: " local_access_key
      if [[ ! -z $local_access_key ]]; then
        ZBR_STORAGE_ACCESS_KEY=$local_access_key
      fi

      read -p "Secret key [$ZBR_STORAGE_SECRET_KEY]: " local_secret_key
      if [[ ! -z $local_secret_key ]]; then
        ZBR_STORAGE_SECRET_KEY=$local_secret_key
      fi

      if [[ $ZBR_REPORTING_ENABLED -eq 0 ]]; then
        export ZBR_MINIO_ENABLED=0
        read -p "[Optional] Tenant [$ZBR_STORAGE_TENANT]: " local_value
        if [[ ! -z $local_value ]]; then
          ZBR_STORAGE_TENANT=$local_value
        fi
      else
        read -p "UserAgent key [$ZBR_STORAGE_AGENT_KEY]: " local_agent_key
        if [[ ! -z $local_agent_key ]]; then
          ZBR_STORAGE_AGENT_KEY=$local_agent_key
        fi
      fi

      echo "Region: $ZBR_STORAGE_REGION"
      echo "Endpoint: $ZBR_STORAGE_ENDPOINT_PROTOCOL://$ZBR_STORAGE_ENDPOINT_HOST"
      echo "Bucket: $ZBR_STORAGE_BUCKET"
      echo "Access key: $ZBR_STORAGE_ACCESS_KEY"
      echo "Secret key: $ZBR_STORAGE_SECRET_KEY"
      echo "Agent key: $ZBR_STORAGE_AGENT_KEY"
      echo "Tenant: $ZBR_STORAGE_TENANT"
      confirm "" "Continue?" "y"
      is_confirmed=$?
    done

    export ZBR_STORAGE_REGION=$ZBR_STORAGE_REGION
    export ZBR_STORAGE_ENDPOINT_PROTOCOL=$ZBR_STORAGE_ENDPOINT_PROTOCOL
    export ZBR_STORAGE_ENDPOINT_HOST=$ZBR_STORAGE_ENDPOINT_HOST
    export ZBR_STORAGE_BUCKET=$ZBR_STORAGE_BUCKET
    export ZBR_STORAGE_ACCESS_KEY=$ZBR_STORAGE_ACCESS_KEY
    export ZBR_STORAGE_SECRET_KEY=$ZBR_STORAGE_SECRET_KEY
    export ZBR_STORAGE_AGENT_KEY=$ZBR_STORAGE_AGENT_KEY
  }

  replace() {
    #TODO: https://github.com/zebrunner/zebrunner/issues/328 organize debug logging for setup/replace
    file=$1
    #echo "file: $file"
    content=$(<$file) # read the file's content into
    #echo "content: $content"

    old=$2
    #echo "old: $old"

    new=$3
    #echo "new: $new"
    content=${content//"$old"/$new}

    #echo "content: $content"

    printf '%s' "$content" >$file    # write new content to disk
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
          setup          Download 2 latest versions of chrome, firefox and opera browsers. Configure S3 storage integration.
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

