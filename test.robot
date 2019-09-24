*** Settings ***
Documentation     Small test harness for the robotframework-selenium-xvfb-firefox-chrome image.
Library           SeleniumLibrary
Library           XvfbRobot

*** Keywords ***
Create Headless Browser
    [Arguments]     ${url}
    Start Virtual Display    1920    1080
    Open Browser   ${url}    ${BROWSER}   options=add_argument("--disable-gpu"); add_argument("--no-sandbox"); add_argument("--disable-extensions")
    Set Window Size    1920    1080

*** Test Cases ***
Test Google
    Create Headless Browser    http://google.com/
    ${title}=    Get Title
    Should Be Equal    Google    ${title}
    Input Text      q   f00bar
    Press Keys      q   RETURN
    Sleep    3
    Capture Page Screenshot
    [Teardown]    Close Browser

Test XPath
    Create Headless Browser   file:///robot/test.html
    Element Text Should Be    xpath://p[@id="paraphraph"]   Lorem ipsum
    Click Button              xpath://input[@value="Squeezeit"]
