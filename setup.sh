#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

if ! which bw >/dev/null; then echo "Please install bitwarden cli https://bitwarden.com/help/cli/"; exit 1; fi
if ! which jq >/dev/null; then echo "Please install jq cli"; exit 1; fi
if ! which docker >/dev/null; then echo "Please install docker cli"; exit 1; fi

"${DIR}/load-credentials.sh"
"${DIR}/setup-ovhai.sh"