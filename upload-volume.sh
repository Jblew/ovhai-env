#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

if [ -z "${UPLOAD_PATH}" ]; then echo "Missing env UPLOAD_PATH"; exit 1; fi
if [ -z "${CHECKSUM}" ]; then echo "Missing env CHECKSUM"; exit 1; fi
if [ -z "${VOLUME_NAME_OUT_FILE}" ]; then echo "Missing env VOLUME_NAME_OUT_FILE"; exit 1; fi

source ../.env
source ovhai.credentials.env

if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME in .env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi

VOLUME_NAME="${IMAGE_NAME}-volume-${NAME}-${CHECKSUM}"
./ovhai data upload "${OVHAI_REGION}" "${VOLUME_NAME}" "${UPLOAD_PATH}" \
    --remove-prefix "${UPLOAD_PATH}"
echo -n "${VOLUME_NAME}" > "${VOLUME_NAME_OUT_FILE}"