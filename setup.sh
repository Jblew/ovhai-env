#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

PROJECT_DIR="${DIR}/.."
source "${DIR}/config.env.sh"
source "${DIR}/ovhai.secrets.env"

if [ -z "${OVHAI_PLATFORM}" ]; then echo "Missing env OVHAI_PLATFORM in config.env.sh"; exit 1; fi
if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME in config.env.sh"; exit 1; fi

if [ -z "${OVHAI_USERNAME}" ]; then echo "Missing env OVHAI_USERNAME in ovhai.secrets.env"; exit 1; fi
if [ -z "${OVHAI_PASSWORD}" ]; then echo "Missing env OVHAI_PASSWORD in ovhai.secrets.env"; exit 1; fi
if [ -z "${OVHAI_PROJECTID}" ]; then echo "Missing env OVHAI_PROJECTID in ovhai.secrets.env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in ovhai.secrets.env"; exit 1; fi
if [ -z "${OVHAI_DOCKER_REGISTRY}" ]; then echo "Missing env OVHAI_DOCKER_REGISTRY in ovhai.secrets.env"; exit 1; fi


install_ovhai() {
    echo "# Installing ovhai cli for platform ${OVHAI_PLATFORM} and region ${OVHAI_REGION}"
    rm -rf ovhai*
    OVHAI_REGION_LOWERCASE=$(echo "${OVHAI_REGION}" | awk '{print tolower($0)}')
    curl -O "https://cli.${OVHAI_REGION_LOWERCASE}.training.ai.cloud.ovh.net/ovhai-${OVHAI_PLATFORM}.zip"
    echo "Unzipping ovhai"
    unzip "ovhai-${OVHAI_PLATFORM}.zip"
    rm -rf "ovhai*.zip"
    echo "Ovhai bin available"
    chmod +x ./ovhai
    echo "Done"
    echo ""
}

login_to_ovhai() {
    echo "# Logging in to ovhai platform"
    ./ovhai login --username "${OVHAI_USERNAME}" --password "${OVHAI_PASSWORD}"
    ./ovhai me --output json > ovhai.me.json
    echo "Done"
    echo ""
}

login_to_ovh_docker_registry() {
    echo "Logging in to docker registry"
    REGISTRY_PREFIX="${OVHAI_DOCKER_REGISTRY}/${OVHAI_PROJECTID}"
    docker login --username "${OVHAI_USERNAME}" --password "${OVHAI_PASSWORD}" "${REGISTRY_PREFIX}"
    echo -n "${REGISTRY_PREFIX}" > docker-registry-prefix.value
    echo "Done"
    echo ""
}

install_ovhai
login_to_ovhai
login_to_ovh_docker_registry


echo "All done. REGION=${OVHAI_REGION}; REGISTRY_PREFIX=${REGISTRY_PREFIX}"