#!/bin/bash

set -eE
set -o pipefail

source <(curl 'https://raw.githubusercontent.com/madworx/cd-ci-glue/master/src/cd-ci-glue.bash')

RELEASEVER="$(date +%Y%m)"
RELEASENAME="$(make get-image-name):${RELEASEVER}"

docker tag $(make get-image-name):latest "${RELEASENAME}"
dockerhub_push_image "$(make get-image-name):latest"
dockerhub_push_image "${RELEASENAME}"

WIKIDIR="$(github_wiki_prepare "madworx/docker-robotframework-selenium-xvfb-firefox-chrome")"

CODIR="$(pwd)"

cd "${WIKIDIR}"
docker inspect "${RELEASENAME}" | jq -r '.[0].Config.Labels' > "${WIKIDIR}/labels-${RELEASEVER}.json"
cp "${CODIR}/README.md" "Home.md"
${CODIR}/tools/generate-version-wiki.py > "Releases.md"
