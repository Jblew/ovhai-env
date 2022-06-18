#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"

source "${DIR}/ovhai.credentials.env"
source "${DIR}/ovhai.config.env"

rm -rf ovhai*
OVHAI_REGION_LOWERCASE=$(echo "${OVHAI_REGION}" | awk '{print tolower($0)}')
curl -O "https://cli.${OVHAI_REGION_LOWERCASE}.training.ai.cloud.ovh.net/ovhai-${OVHAI_PLATFORM}.zip"
unzip "ovhai-${OVHAI_PLATFORM}.zip"
chmod +x ovhai

./ovhai login --username "${OVHAI_USERNAME}" --password "${OVHAI_PASSWORD}"
./ovhai me > ovhai.me