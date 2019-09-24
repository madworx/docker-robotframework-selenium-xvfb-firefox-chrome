all:	docker-build

IMAGE_NAME := madworx/robotframework-selenium-xvfb-firefox-chrome

RUNCMD := docker run --rm -it -v $$(pwd):/robot $(IMAGE_NAME) -L TRACE 

docker-build:
	docker build -t $(IMAGE_NAME) .

tests: docker-build
	$(RUNCMD) -v BROWSER:Chrome  -d out-chrome  .
	$(RUNCMD) -v BROWSER:firefox -d out-firefox .

.PHONY: tests docker-build all