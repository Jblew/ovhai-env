#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${DIR}/.."
cd "${DIR}"
set -e

source "${PROJECT_DIR}/.env"
source "${DIR}/ovhai.credentials.env"
if [ -z "${JOBS_DIR}" ]; then echo "Missing env JOBS_DIR in .env"; exit 1; fi
if [ -z "${VOLUME_OUTPUTS_NAME_BASE}" ]; then echo "Missing env VOLUME_OUTPUTS_NAME_BASE in .env"; exit 1; fi
if [ -z "${OVHAI_REGION}" ]; then echo "Missing env OVHAI_REGION in env/ovhai.credentials.env"; exit 1; fi

for JOB_DIR in "${JOBS_DIR}"/*/ ; do
    LOG_FILE="${JOB_DIR}/job.log"
    if [ ! -f "$LOG_FILE" ]; then
        echo "Downloding logs and outputs for ${JOB_DIR}"
        JOB_ID_FILE="${JOB_DIR}/id"
        OVHAI_JOB_ID="$(cat "${JOB_ID_FILE}")"
        ./ovhai job logs -f "${OVHAI_JOB_ID}" | tee "${LOG_FILE}"
        VOLUME_NAME_FILE="${JOB_DIR}/outputs.volume.name"
        VOLUME_OUTPUTS_NAME="$(cat "${VOLUME_NAME_FILE}")"
        VOLUME_OUTPUTS_DIR="${JOB_DIR}/outputs"
        ./ovhai data download "${OVHAI_REGION}" "${VOLUME_OUTPUTS_NAME}" \
            --output "${VOLUME_OUTPUTS_DIR}/"
    else
        echo "Job ${JOB_DIR} already has logs downloaded to ${LOG_FILE}"
    fi
done

echo "Done"