FROM debian:bullseye-slim

ARG VCS_REF="unspecified"

LABEL maintainer="martin.kjellstrand@madworx.se" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-url="https://github.com/madworx/docker-robotframework-selenium-xvfb-firefox-chrome.git" \
      org.label-schema.vcs-ref="${VCS_REF}"

# Install dependencies + Mozilla Firefox
RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        python3-pip firefox-esr xvfb curl

# Install Google Chrome
RUN curl -sSfL -o google-chrome-stable_current_amd64.deb \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install --assume-yes --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# Install Robot Framework + SeleniumLibrary.
RUN pip3 install setuptools wheel \
    && pip3 install robotframework robotframework-seleniumlibrary \
        robotframework-xvfb webdrivermanager

# Download matching webdrivers for Firefox and Chrome.
RUN webdrivermanager firefox chrome --linkpath /usr/local/bin

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
