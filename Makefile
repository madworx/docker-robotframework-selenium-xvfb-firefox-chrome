all:	docker-build
.ONESHELL:

IMAGE_NAME := madworx/robotframework-selenium-xvfb-firefox-chrome

RUNCMD := docker run --rm -it -v $$(pwd):/robot $(IMAGE_NAME) -L TRACE
GETVER := docker run --rm --entrypoint=/bin/cat $(IMAGE_NAME) /versions.txt

docker-build:
	docker build -t $(IMAGE_NAME) --build-arg VCS_REF=$$(git log --pretty=format:'%h' -n 1) .

tests: docker-build
	$(RUNCMD) -v BROWSER:Chrome  -d out-chrome  .
	$(RUNCMD) -v BROWSER:firefox -d out-firefox .

docker-label-versions: docker-build
	echo -n "FROM $(IMAGE_NAME)\nLABEL `$(GETVER) | sed 's#^#org.madworx.software.#' | tr '[\n]' ' '`" | docker build -t $(IMAGE_NAME) -f - .
	docker inspect --format '{{ .Config.Labels }}' madworx/robotframework-selenium-xvfb-firefox-chrome
	
get-image-name:
	@echo $(IMAGE_NAME)

release:
	./tools/make-release.sh

.PHONY: release get-image-name docker-label-versions tests docker-build all

# docker inspect madworx/robotframework-selenium-xvfb-firefox-chrome | jq -r '.[0].Config.Labels' | jq -r 'to_entries[] | "\(.key)=\(.value)"'
# 
