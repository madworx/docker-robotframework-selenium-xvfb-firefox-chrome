#!/usr/bin/env python3

import json
import re
import sys
from glob import glob
from pprint import pprint

# We need 3.6 to ensure dicts iterate over insertion order.
assert sys.version_info >= (3, 6), "{} is not a supported version".format(sys.version_info)

categories = {
    'browser' : {
        'chrome':       'Chrome',
        'chromedriver': 'ChromeDriver',
        'firefox':      'Firefox',
        'geckodriver':  'GeckoDriver' ,
    },
    'others' : {
        'python':          'Python',
        'robotframework':  'RobotFramework' ,
        'seleniumlibrary': 'SeleniumLibrary',
        'xvfbrobot':       'XvfbRobot',
    }
}

images = {}
for filename in glob("labels-[0-9][0-9][0-9][0-9][0-9][0-9].json"):
    with open(filename, "r") as f:
        labels = json.loads(f.read())
        versions = { k[21:]: v
                     for (k,v) in labels.items()
                        if k.startswith("org.madworx.software") }
        images[filename[7:13]] = versions

out = {}
for image, labels in images.items():
    for label in labels:
        found = False
        for (category, props) in categories.items():
            if not found:
                for key, value in props.items():
                    if not category in out: out[category] = {}
                    if not value in out[category]: out[category][value] = {}
                    if re.match(r'^'+key+'$', label):
                        if not image in out[category][value]:
                            out[category][value][image] = images[image][label]
                            found = True
        if not found:
            if not label in out['others']:
                out['others'][label] = {}
            out['others'][label][image] = labels[label]

for category, images in out.items():
    if category == 'browser':
        print( "### Browser and driver versions")
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

    str = "| {} "
    str = "| Release |"
    for software, width in widths.items():
        str = str + " " + software + " " + " "*(width-len(software)) + "|"
    divider = re.sub(r'[^|]', '-', str)
    print()
    print(str)
    print(divider)

    for release in sorted(releases, reverse=True):
        s = "| " + release + "  |"
        for software, width in widths.items():
            softver = images[software][release] if release in images[software] else ""
            s = s + " {0: <{1}} |".format(softver, width)
        print(s)

    print()
