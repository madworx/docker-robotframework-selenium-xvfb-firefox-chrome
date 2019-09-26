#!/usr/bin/env python3

import json
import re
import sys
from glob import glob

# We need 3.6 to ensure dicts iterate over insertion order.
assert sys.version_info >= (3, 6),\
    "{} is not a supported version".format(sys.version_info)

CATEGORIES = {
    'browser': {
        'chrome':          'Chrome',
        'chromedriver':    'ChromeDriver',
        'firefox':         'Firefox',
        'geckodriver':     'GeckoDriver',
    },
    'others': {
        'python':          'Python',
        'robotframework':  'RobotFramework',
        'seleniumlibrary': 'SeleniumLibrary',
        'xvfbrobot':       'XvfbRobot',
    }
}

IMAGES = {}
for filename in glob("labels-[0-9][0-9][0-9][0-9][0-9][0-9].json"):
    with open(filename, "r") as f:
        labels = json.loads(f.read())
        versions = {k[21:]: v
                    for (k, v) in labels.items()
                    if k.startswith("org.madworx.software")}
        IMAGES[filename[7:13]] = versions

TABLE = {}
for image, labels in IMAGES.items():
    for label in labels:
        found = False
        for (category, props) in CATEGORIES.items():
            if not found:
                for key, value in props.items():
                    if category not in TABLE:
                        TABLE[category] = {}
                    if value not in TABLE[category]:
                        TABLE[category][value] = {}
                    if re.match(r'^'+key+'$', label):
                        if image not in TABLE[category][value]:
                            TABLE[category][value][image] = \
                                IMAGES[image][label]
                            found = True
        if not found:
            if label not in TABLE['others']:
                TABLE['others'][label] = {}
            TABLE['others'][label][image] = labels[label]

for category, images in TABLE.items():
    if category == 'browser':
        print("### Browser and driver versions")
    elif category == 'others':
        print("### Software component versions")
    else:
        raise Error("Nobody expects the spanish inquisition...")

    widths = {}
    releases = set()
    for software, versions in images.items():
        widths[software] = []
        widths[software].append(len(software))
        for version in versions.values():
            widths[software].append(len(version))
        widths[software] = max(widths[software])
        for release in versions.keys():
            releases.add(release)

    header = "| {} "
    header = "| Release |"
    for software, width in widths.items():
        header = header + " {0: <{1}} |".format(software, width)
    divider = re.sub(r'[^|]', '-', header)
    print()
    print(header)
    print(divider)

    for release in sorted(releases, reverse=True):
        line = "| " + release + "  |"
        for software, width in widths.items():
            softver = images[software][release] if release in images[software] else ""
            line = line + " {0: <{1}} |".format(softver, width)
        print(line)

    print()
