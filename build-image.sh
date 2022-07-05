#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
PROJECT_DIR="${DIR}/.."

source "${PROJECT_DIR}/.env"
if [ -z "${IMAGE_NAME}" ]; then echo "Missing env IMAGE_NAME in .env"; exit 1; fi
if [ -z "${IMAGE_DIR}" ]; then echo "Missing env IMAGE_DIR in .env"; exit 1; fi

DOCKER_REGISTRY_PREFIX_VALUEFILE="${DIR}/docker-registry-prefix.value"
DOCKER_REGISTRY_PREFIX=$(cat "${DOCKER_REGISTRY_PREFIX_VALUEFILE}")
if [ -z "${DOCKER_REGISTRY_PREFIX}" ]; then echo "Could not load DOCKER_REGISTRY_PREFIX from valuefile ${DOCKER_REGISTRY_PREFIX_VALUEFILE}"; exit 1; fi

echo "Building image ${IMAGE_NAME} from ${IMAGE_DIR}"
docker build -t "${IMAGE_NAME}" "${IMAGE_DIR}"
docker tag ${IMAGE_NAME} "${DOCKER_REGISTRY_PREFIX}/${IMAGE_NAME}"

echo "Pusing ${DOCKER_REGISTRY_PREFIX}/${IMAGE_NAME} to registry"
docker push "${DOCKER_REGISTRY_PREFIX}/${IMAGE_NAME}"
echo -n "$(docker images -q ${IMAGE_NAME} | awk 'NR==1')" > "${PROJECT_DIR}/.image.id"
echo "Done"