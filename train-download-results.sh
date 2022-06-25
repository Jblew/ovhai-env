#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

if [ -z "${JOB_ID_FILE}" ]; then echo "Missing env JOB_ID_FILE"; exit 1; fi
if [ -z "${VOLUMENAME_PATH_OUTPUTS}" ]; then echo "Missing env VOLUMENAME_PATH_OUTPUTS"; exit 1; fi
if [ -z "${OUTPUTS_PATH}" ]; then echo "Missing env OUTPUTS_PATH"; exit 1; fi

source "${DIR}/ovhai.credentials.env"
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi

VOLUME_OUTPUTS="$(cat "${VOLUMENAME_PATH_OUTPUTS}")"
OVHAI_JOB_ID="$(cat "${JOB_ID_FILE}")"

./ovhai job logs -f "${OVHAI_JOB_ID}"
./ovhai data download "${OVHAI_REGION}" "${VOLUME_OUTPUTS}" \
    --output "${OUTPUTS_PATH}/"

echo "Done"