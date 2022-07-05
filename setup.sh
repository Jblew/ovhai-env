#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e

"${DIR}/setup-load-credentials.sh"
"${DIR}/setup-ovhai.sh"