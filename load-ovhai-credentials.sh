#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

BITWARDEN_CREDENTIALS_SECRET_NAME="ovhai_jjworkj_credentials"

if ! which bw >/dev/null; then
  echo "Please install bitwarden cli https://bitwarden.com/help/cli/"
  exit
fi

if ! bw list items --search "asdf" > /dev/null 2>&1; then
   echo "Please login & unlock bitwarden (with exporting BW_SESSION)" > /dev/stderr
   exit
fi

USERNAME=$(bw get username "${BITWARDEN_CREDENTIALS_SECRET_NAME}")
PASSWORD=$(bw get password "${BITWARDEN_CREDENTIALS_SECRET_NAME}")
PROJECTID=$(bw get item "${BITWARDEN_CREDENTIALS_SECRET_NAME}" | jq --raw-output '.fields[] | select(.name | contains("projectid")) | .value')
REGION=$(bw get item "${BITWARDEN_CREDENTIALS_SECRET_NAME}" | jq --raw-output '.fields[] | select(.name | contains("region")) | .value')
DOCKER_REGISTRY=$(bw get item "${BITWARDEN_CREDENTIALS_SECRET_NAME}" | jq --raw-output '.fields[] | select(.name | contains("docker-registry")) | .value')

 
echo "
OVHAI_USERNAME=\"${USERNAME}\"
OVHAI_PASSWORD=\"${PASSWORD}\"
OVHAI_PROJECTID=\"${PROJECTID}\"
OVHAI_REGION=\"${REGION}\"
OVHAI_DOCKER_REGISTRY=\"${DOCKER_REGISTRY}\"
" > "${DIR}/ovhai.credentials.env"