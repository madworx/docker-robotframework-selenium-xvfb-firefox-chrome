FROM debian:bookworm-slim

ARG VCS_REF="unspecified"

LABEL maintainer="martin.kjellstrand@madworx.se" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-url="https://github.com/madworx/docker-robotframework-selenium-xvfb-firefox-chrome.git" \
      org.label-schema.vcs-ref="${VCS_REF}"

# Install dependencies
RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        python3-pip xvfb curl jq

# Install Firefox from Debian unstable.
RUN echo "deb http://cdn-fastly.deb.debian.org/debian sid main" >> /etc/apt/sources.list \
    && echo "\nPackage: *\nPin: release a=unstable\nPin-Priority: 600\n" >> /etc/apt/preferences \
    && apt-get update \
    && apt-get install --assume-yes -t sid firefox

# Install Google Chrome
RUN curl -sSfLO 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' \
    && apt install --assume-yes --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# Install Robot Framework + SeleniumLibrary.
RUN pip3 install setuptools wheel \
    && pip3 install robotframework robotframework-seleniumlibrary \
        robotframework-xvfb webdrivermanager

# Download matching webdriver for Chrome.
RUN webdrivermanager chrome --linkpath /usr/local/bin

# Download latest webdriver for Firefox ("webdrivermanager" doesn't seem to be updated...)
RUN curl 'https://api.github.com/repos/mozilla/geckodriver/releases' \
    | jq -r '.[0].assets[].browser_download_url|match("(.+linux64.tar.gz)$")|.string' \
    | xargs curl -sSfLO \
    && tar xf geckodriver-*-linux64.tar.gz \
    && mv geckodriver /usr/local/bin/ \
    && rm geckodriver-*-linux64.tar.gz

# Generate a list of software and library versions in /versions.txt.
RUN (/opt/google/chrome/chrome --version | sed 's#Google Chrome \([^ ]*\).*#chrome=\1#' ; \
     chromedriver --version | sed 's#ChromeDriver \([^ ]*\).*#chromedriver=\1#' ; \
     firefox --version | sed 's#Mozilla Firefox #firefox=#' ; \
     geckodriver --version | head -n1 | sed 's#\(geckodriver\) \([^ ]*\).*#\1=\2#' ; \
     robot --version | sed 's#Robot Framework \([^ ]*\).*#robotframework=\1#' ; \
     python3 -c 'import SeleniumLibrary; print("seleniumlibrary={}".format(SeleniumLibrary.__version__));' ; \
     python3 -c 'import XvfbRobot; print("xvfbrobot={}".format(XvfbRobot.__version__));' ; \
     python3 --version | sed 's#Python #python=#' \
     ) > /versions.txt

WORKDIR /robot
ENTRYPOINT ["/usr/local/bin/robot", "--outputdir", "output"]
CMD [ "." ]
