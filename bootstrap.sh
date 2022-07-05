#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${DIR}/.."
cd "${DIR}"

if ! which bw >/dev/null; then echo "Please install bitwarden cli https://bitwarden.com/help/cli/"; exit 1; fi
if ! which jq >/dev/null; then echo "Please install jq cli"; exit 1; fi
if ! which docker >/dev/null; then echo "Please install docker cli"; exit 1; fi

source .env.sample
cp "${DIR}/.env.sample" "${PROJECT_DIR}/.env"
mkdir -p "${IMAGE_DIR}"
mkdir -p "${VOLUME_DATA_DIR}"
mkdir -p "${VOLUME_SRC_DIR}"
mkdir -p "${JOBS_DIR}"
if [ ! -f "${PARAMSJSON_FILE}" ]; then
    echo "{\"train\":{}}" > "${PARAMSJSON_FILE}"
fi