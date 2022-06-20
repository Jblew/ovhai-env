#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

PROJECT_DIR="${DIR}/.."
source "${DIR}/config.env.sh"

if [ -z "${OVHAI_PLATFORM}" ]; then echo "Missing env OVHAI_PLATFORM"; exit; fi
if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME"; exit; fi
if [ -z "${BITWARDEN_OVHAI_SECRET}" ]; then echo "Missing env BITWARDEN_OVHAI_SECRET"; exit; fi

load_ovhai_credentials() {
    echo "# Loading credentials from bitwarden"

    if ! which bw >/dev/null; then
    echo "Please install bitwarden cli https://bitwarden.com/help/cli/"
    exit
    fi

    if ! bw list items --search "asdf" > /dev/null 2>&1; then
    echo "Please login & unlock bitwarden (with exporting BW_SESSION)" > /dev/stderr
    exit
    fi

    OVHAI_USERNAME=$(bw get username "${BITWARDEN_OVHAI_SECRET}")
    OVHAI_PASSWORD=$(bw get password "${BITWARDEN_OVHAI_SECRET}")
    OVHAI_PROJECTID=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("projectid")) | .value')
    OVHAI_REGION=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("region")) | .value')
    OVHAI_DOCKER_REGISTRY=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("docker-registry")) | .value')

    if [ -z "${OVHAI_USERNAME}" ]; then echo "Could not load '.username' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit; fi
    if [ -z "${OVHAI_PASSWORD}" ]; then echo "Could not load '.password' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit; fi
    if [ -z "${OVHAI_PROJECTID}" ]; then echo "Could not load '.fields[name=projectid].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit; fi
    if [ -z "${OVHAI_REGION}" ]; then echo "Could not load '.fields[name=region].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit; fi
    if [ -z "${OVHAI_DOCKER_REGISTRY}" ]; then echo "Could not load '.fields[name=docker-registry].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit; fi

    echo "Done"
    echo ""
}

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
    echo "${REGISTRY_PREFIX}" > docker-registry-prefix.value
    echo "Done"
    echo ""
}

load_ovhai_credentials
install_ovhai
login_to_ovhai
login_to_ovh_docker_registry


echo "All done. REGION=${OVHAI_REGION}; REGISTRY_PREFIX=${REGISTRY_PREFIX}"