FROM debian:bullseye-slim

LABEL maintainer="martin.kjellstrand@madworx.se"

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        python3-pip firefox-esr xvfb curl

RUN pip3 install setuptools wheel \
    && pip3 install robotframework robotframework-seleniumlibrary \
        robotframework-xvfb webdrivermanager

RUN curl -sSfL -o google-chrome-stable_current_amd64.deb \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install --assume-yes --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

RUN webdrivermanager firefox chrome --linkpath /usr/local/bin

WORKDIR /robot

ENTRYPOINT ["/usr/local/bin/robot", "--outputdir", "output"]
CMD [ "." ]