# ovhai-env
Environment for AI training management on OVHAI



## Setup:

1. Install required CLI tools: Bash, Docker, [Bitwarden CLI](https://bitwarden.com/help/cli/), [jq CLI](https://stedolan.github.io/jq/).

2. Create or share bitwarden secrets for S3 and ovhai. Required fields:

   1. S3 (for DVC): custom fields named `accesskeyid` and `secretaccesskey`
   2. OVHAI:
      1. username — ovhcloud nichandle username (the restricted user credentials not the owner one!)
      2. password — ovhcloud nichandle password
      3. custom field named `projectid` — ovh public cloud project id
      4. custom field named `region` — ovh public cloud region uppercase e.g. `GRA`
      5. custom field named `docker-registry` — URL of ovhai docker registry

3. Add ovhai-env as a submodule: 

   ```bash
   $ git submodule init
   $ git submodule add git@github.com/Jblew/ovhai-env.git env
   ```

4. Run `env/bootstrap.sh`

5. Configure environment in `.env`

   ```bash
   OVHAI_PLATFORM="darwin"
   IMAGE_NAME="cnn-tutorial"
   BITWARDEN_DVC_S3_CREDENTIALS_SECRET="name-of-the-bitwarden-secret"
   BITWARDEN_OVHAI_SECRET="..."
   IMAGE_DIR="${PROJECT_DIR}/image"
   IMAGE_ID_OUT_FILE="${PROJECT_DIR}/.image.id"
   DVC_S3_CREDENTIALS_OUT_FILE="${PROJECT_DIR}/.dvc/aws.credentials"
   OVHAI_CPU_COUNT=2
   OVHAI_GPU_COUNT=1
   CONTAINER_WORKDIR="/w"
   CONTAINER_CMD="python src/train.py"
   VOLUME_DATA_DIR="${PROJECT_DIR}/data"
   VOLUME_DATA_MOUNT="/w/data"
   VOLUME_DATA_NAME="cnn-tutorial-data"
   VOLUME_SRC_DIR="${PROJECT_DIR}/src"
   VOLUME_SRC_MOUNT="/w/src"
   VOLUME_SRC_NAME="cnn-tutorial-src"
   JOBS_DIR="${PROJECT_DIR}/jobs"
   VOLUME_OUTPUTS_MOUNT="/w/outputs"
   VOLUME_OUTPUTS_NAME_BASE="cnn-tutorial-outputs-"
   PARAMSJSON_FILE="${PROJECT_DIR}/params.json"
   CONTAINER_PARAMSJSON_ENV_NAME="PARAMSJSON"
   ```

6. Run `env/setup.sh` to install and configure environment



## Usage:

1. Run `env/image-build.sh` to build docker image and push to ovhai registry

2. Run job `env/train-on-ovhai.sh`. This will create a directory for this experiment in the `jobs/` with configuration files that will be used in the next step to obtain correct results.

3. Get logs and download results using `env/results-download.sh`. This command will download logs and outputs for any subdirectory in `jobs/` that does not already have them downloaded

