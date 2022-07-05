#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${DIR}/.."
cd "${DIR}"
set -e

source "${DIR}/../.env"
source "${DIR}/ovhai.credentials.env"
if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME in .env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi
if [ -z "${JOB_STATUS_JSON_FILE}" ]; then echo "Missing env JOB_STATUS_JSON_FILE in .env file"; exit 1; fi
if [ -z "${JOB_STATUS_ID_FILE}" ]; then echo "Missing env JOB_STATUS_ID_FILE in .env file"; exit 1; fi
if [ -z "${VOLUME_DATA_NAME}" ]; then echo "Missing env VOLUME_DATA_NAME in .env file"; exit 1; fi
if [ -z "${VOLUME_DATA_DIR}" ]; then echo "Missing env VOLUME_DATA_DIR in .env file"; exit 1; fi
if [ -z "${VOLUME_DATA_MOUNT}" ]; then echo "Missing env VOLUME_DATA_MOUNT in .env file"; exit 1; fi
if [ -z "${VOLUME_SRC_NAME}" ]; then echo "Missing env VOLUME_SRC_NAME in .env file"; exit 1; fi
if [ -z "${VOLUME_SRC_DIR}" ]; then echo "Missing env VOLUME_SRC_DIR in .env file"; exit 1; fi
if [ -z "${VOLUME_SRC_MOUNT}" ]; then echo "Missing env VOLUME_SRC_MOUNT in .env file"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_NAME}" ]; then echo "Missing env VOLUME_OUTPUTS_NAME in .env file"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_DIR}" ]; then echo "Missing env VOLUME_OUTPUTS_DIR in .env file"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_MOUNT}" ]; then echo "Missing env VOLUME_OUTPUTS_MOUNT in .env file"; exit 1; fi
if [ -z "${CONTAINER_WORKDIR}" ]; then echo "Missing env CONTAINER_WORKDIR in .env file"; exit 1; fi
if [ -z "${CONTAINER_CMD}" ]; then echo "Missing env CONTAINER_CMD in .env file"; exit 1; fi
if [ -z "${OVHAI_CPU_COUNT}" ]; then echo "Missing env OVHAI_CPU_COUNT in .env file"; exit 1; fi
if [ -z "${OVHAI_GPU_COUNT}" ]; then echo "Missing env OVHAI_GPU_COUNT in .env file"; exit 1; fi
if [ -z "${CONTAINER_PARAMSJSON_ENV_NAME}" ]; then echo "Missing env CONTAINER_PARAMSJSON_ENV_NAME in .env file"; exit 1; fi
if [ -z "${PARAMSJSON_FILE}" ]; then echo "Missing env PARAMSJSON_FILE in .env file"; exit 1; fi

DOCKER_REGISTRY_PREFIX=$(cat "${DIR}/docker-registry-prefix.value")
if [ -z "${DOCKER_REGISTRY_PREFIX}" ]; then echo "Missing docker registry prefix in in env/docker-registry-prefix.value. Di you publish the image?"; exit 1; fi

echo "Uploading data volume"
./ovhai data upload "${OVHAI_REGION}" "${VOLUME_DATA_NAME}" "${VOLUME_DATA_DIR}" --remove-prefix "${VOLUME_DATA_DIR}/"
echo "Uploading src volume"
./ovhai data upload "${OVHAI_REGION}" "${VOLUME_SRC_NAME}" "${VOLUME_SRC_DIR}" --remove-prefix "${VOLUME_SRC_DIR}/"
echo "Uploading outputs volume"
./ovhai data upload "${OVHAI_REGION}" "${VOLUME_OUTPUTS_NAME}" "${VOLUME_OUTPUTS_DIR}" --remove-prefix "${VOLUME_OUTPUTS_DIR}/"
echo "Done uploading volumes"

echo "Starting training job on OVHAI"
# Run the job
IMAGE_PATH="${DOCKER_REGISTRY_PREFIX}/${IMAGE_NAME}"
PARAMSJSON=$(cat "${PARAMSJSON_FILE} | jq -c)
./ovhai job run "${IMAGE_PATH}" \
    --cpu "${OVHAI_CPU_COUNT}" --gpu "${OVHAI_GPU_COUNT}" \
    -v "${VOLUME_DATA_NAME}:${VOLUME_DATA_MOUNT}:ro" \
    -v "${VOLUME_SRC_NAME}:${VOLUME_SRC_MOUNT}:ro" \
    -v "${VOLUME_OUTPUTS_NAME}:${VOLUME_OUTPUTS_MOUNT}:rw" \
    --output json \
    --env "${CONTAINER_PARAMSJSON_ENV_NAME}=${PARAMSJSON}" \
    -- bash -c "sleep 7 && du -ha ${CONTAINER_WORKDIR} && cd ${CONTAINER_WORKDIR} && ${CONTAINER_CMD}" \
    > "${JOB_STATUS_JSON_FILE}"

OVHAI_JOB_ID="$(cat "${JOB_STATUS_JSON_FILE}" | jq  -r '.id')"
echo -n "${OVHAI_JOB_ID}" > "${JOB_STATUS_ID_FILE}"
