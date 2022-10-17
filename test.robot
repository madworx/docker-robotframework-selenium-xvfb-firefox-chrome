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
    Create Headless Browser     http://google.com/
    ${title}=                   Get Title
    Should Be Equal             Google    ${title}
    ${count}=                   Get Matching XPath Count     xpath://button[@id="L2AGLb"]
    Run Keyword And Return If   ${count} > 0   Click Button  xpath://button[@id="L2AGLb"]
    Press Keys                  q   RETURN
    Sleep                       3
    Capture Page Screenshot

Test XPath
    Create Headless Browser   file:///robot/test.html
    Element Text Should Be    xpath://p[@id="paraphraph"]   Lorem ipsum
    Click Button              xpath://input[@value="Squeezeit"]

Test click by link text
    Click Element             link:This is a link to google
    Sleep    3
    ${title}=    Get Title
    Should Be Equal    Google    ${title}
