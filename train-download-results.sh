#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${DIR}/.."
cd "${DIR}"
set -e

source "${PROJECT_DIR}/.env"
source "${DIR}/ovhai.credentials.env"
if [ -z "${JOB_STATUS_ID_FILE}" ]; then echo "Missing env JOB_STATUS_ID_FILE in .env"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_NAME}" ]; then echo "Missing env VOLUME_OUTPUTS_NAME in .env"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_DIR}" ]; then echo "Missing env VOLUME_OUTPUTS_DIR in .env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi

OVHAI_JOB_ID="$(cat "${JOB_STATUS_ID_FILE}")"
./ovhai job logs -f "${OVHAI_JOB_ID}"
./ovhai data download "${OVHAI_REGION}" "${VOLUME_OUTPUTS_NAME}" \
    --output "${VOLUME_OUTPUTS_DIR}/"

echo "Done"