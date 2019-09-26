#!/bin/bash

set -eE
set -o pipefail
set -x

source <(curl 'https://raw.githubusercontent.com/madworx/cd-ci-glue/master/src/cd-ci-glue.bash')

IMAGE_NAME="$(make -s get-image-name)"
RELEASEVER="$(date +%Y%m)"
RELEASENAME="${IMAGE_NAME}:${RELEASEVER}"

docker tag "${IMAGE_NAME}:latest" "${RELEASENAME}"
dockerhub_push_image "${RELEASENAME}"
dockerhub_push_image "${IMAGE_NAME}:latest"

CODIR="$(pwd)"
WIKIDIR="$(github_wiki_prepare "madworx/docker-robotframework-selenium-xvfb-firefox-chrome")"

cd "${WIKIDIR}"
docker inspect "${RELEASENAME}" | jq -r '.[0].Config.Labels' > "labels-${RELEASEVER}.json"
cp "${CODIR}/README.md" "Home.md"
${CODIR}/tools/generate-version-wiki.py > "Releases.md"

cd "${CODIR}"
github_wiki_commit "${WIKIDIR}"
