#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

if [ -z "${JOB_STATUS_FILE}" ]; then echo "Missing env JOB_STATUS_FILE"; exit 1; fi
if [ -z "${JOB_ID_FILE}" ]; then echo "Missing env JOB_ID_FILE"; exit 1; fi
if [ -z "${VOLUMENAME_PATH_SRC}" ]; then echo "Missing env VOLUME_PATH_SRC"; exit 1; fi
if [ -z "${VOLUMENAME_PATH_DATA}" ]; then echo "Missing env VOLUMENAME_PATH_DATA"; exit 1; fi
if [ -z "${VOLUMENAME_PATH_PARAMSYML}" ]; then echo "Missing env VOLUMENAME_PATH_PARAMSYML"; exit 1; fi
if [ -z "${VOLUMENAME_PATH_OUTPUTS}" ]; then echo "Missing env VOLUMENAME_PATH_OUTPUTS"; exit 1; fi

source "${DIR}/../.env"
source "${DIR}/ovhai.credentials.env"

if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME in .env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi

DOCKER_REGISTRY_PREFIX=$(cat "${DIR}/docker-registry-prefix.value")
if [ -z "${DOCKER_REGISTRY_PREFIX}" ]; then echo "Missing docker registry prefix in in env/docker-registry-prefix.value"; exit 1; fi

# Run the job
IMAGE_PATH="${DOCKER_REGISTRY_PREFIX}/${IMAGE_NAME}"
VOLUME_SRC="$(cat "${VOLUMENAME_PATH_SRC}")@${OVHAI_REGION}"
VOLUME_DATA="$(cat "${VOLUMENAME_PATH_DATA}")@${OVHAI_REGION}"
VOLUME_PARAMSYML="$(cat "${VOLUMENAME_PATH_PARAMSYML}")@${OVHAI_REGION}"
VOLUME_OUTPUTS="$(cat "${VOLUMENAME_PATH_OUTPUTS}")@${OVHAI_REGION}"
echo "Image: ${IMAGE_PATH}"
env/ovhai job run "${IMAGE_PATH}" \
    --cpu 2 --gpu 1 \
    -v "${VOLUME_SRC}:/workdir/src:ro" \
    -v "${VOLUME_DATA}:/workdir/data:ro" \
    -v "${VOLUME_PARAMSYML}:/workdir/params.yml:ro" \
    -v "${VOLUME_OUTPUTS}:/workdir/outputs:rw" \
    --output json \
    -- bash -c "du -ha /workdir && du -ha /outputs && cd /workdir && python src/train.py" \
    > "${JOB_STATUS_FILE}"

OVHAI_JOB_ID="$(cat "${JOB_STATUS_FILE}" | jq  -r '.id')"
echo -n "${OVHAI_JOB_ID}" > "${JOB_ID_FILE}"
