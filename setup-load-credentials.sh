#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${DIR}/.."
cd "${DIR}"
set -e

source "${DIR}/../.env"
if [ -z "${DVC_S3_CREDENTIALS_OUT_FILE}" ]; then echo "Missing env DVC_S3_CREDENTIALS_OUT_FILE in .env"; exit 1; fi
if [ -z "${BITWARDEN_DVC_S3_CREDENTIALS_SECRET}" ]; then echo "Missing env BITWARDEN_DVC_S3_CREDENTIALS_SECRET in .env"; exit 1; fi
if [ -z "${BITWARDEN_OVHAI_SECRET}" ]; then echo "Missing env BITWARDEN_OVHAI_SECRET in .env"; exit 1; fi

OVHAI_CREDENTIALS_OUT_PATH="${DIR}/../env/ovhai.credentials.env"

unlock_bitwarden() {
    echo "# Unlocking bitwarden"
    export BW_SESSION="$(bw unlock --raw)"

    echo "Done"
    echo ""
}

load_dvc_s3_credentials() {
    echo "# Loading DVC credentials from bitwarden"

    AWS_ACCESSKEYID=$(bw get item "${BITWARDEN_DVC_S3_CREDENTIALS_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("accesskeyid")) | .value')
    AWS_SECRETACCESSKEY=$(bw get item "${BITWARDEN_DVC_S3_CREDENTIALS_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("secretaccesskey")) | .value')

    if [ -z "${AWS_ACCESSKEYID}" ]; then echo "Could not load '.fields[name=accesskeyid].value' from bitwarden secret ${BITWARDEN_DVC_S3_CREDENTIALS_SECRET}"; exit 1; fi
    if [ -z "${AWS_SECRETACCESSKEY}" ]; then echo "Could not load '.fields[name=secretaccesskey].value' from bitwarden secret ${BITWARDEN_DVC_S3_CREDENTIALS_SECRET}"; exit 1; fi

    echo "[default]
aws_access_key_id=${AWS_ACCESSKEYID}
aws_secret_access_key=${AWS_SECRETACCESSKEY}
    " > "${DVC_S3_CREDENTIALS_OUT_FILE}"

    echo "Done"
    echo ""
}

load_ovhai_credentials() {
    echo "# Loading OVHAI credentials from bitwarden"

    OVHAI_USERNAME=$(bw get username "${BITWARDEN_OVHAI_SECRET}")
    OVHAI_PASSWORD=$(bw get password "${BITWARDEN_OVHAI_SECRET}")
    OVHAI_PROJECTID=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("projectid")) | .value')
    OVHAI_REGION=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("region")) | .value')
    OVHAI_DOCKER_REGISTRY=$(bw get item "${BITWARDEN_OVHAI_SECRET}" | jq --raw-output '.fields[] | select(.name | contains("docker-registry")) | .value')

    if [ -z "${OVHAI_USERNAME}" ]; then echo "Could not load '.username' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit 1; fi
    if [ -z "${OVHAI_PASSWORD}" ]; then echo "Could not load '.password' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit 1; fi
    if [ -z "${OVHAI_PROJECTID}" ]; then echo "Could not load '.fields[name=projectid].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit 1; fi
    if [ -z "${OVHAI_REGION}" ]; then echo "Could not load '.fields[name=region].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit 1; fi
    if [ -z "${OVHAI_DOCKER_REGISTRY}" ]; then echo "Could not load '.fields[name=docker-registry].value' from bitwarden secret ${BITWARDEN_OVHAI_SECRET}"; exit 1; fi

    echo "
OVHAI_USERNAME=${OVHAI_USERNAME}
OVHAI_PASSWORD=${OVHAI_PASSWORD}
OVHAI_PROJECTID=${OVHAI_PROJECTID}
OVHAI_REGION=${OVHAI_REGION}
OVHAI_DOCKER_REGISTRY=${OVHAI_DOCKER_REGISTRY}
    " > "${OVHAI_CREDENTIALS_OUT_PATH}"

    echo "Done"
    echo ""
}

unlock_bitwarden
load_dvc_s3_credentials
load_ovhai_credentials

echo "# Loading credentials done"