*** Settings ***
Documentation    Testing feature 1 

Resource    ../../../Resources/Common.robot
Resource    ../../../Resources/PageObject/HomePage.robot

Test Setup    Common.Open webbrowser

*** Variables ***

           
*** Test Cases ***                    #${Acount_to_deactivate_email}        ${Acount_to_deactivate_Password}
        
TC1    
    [Tags]    Smoke   Regression
    open application website
    Log   rest of steps here

TC2           
    [Tags]    Regression
    open application website
    Log   rest of steps here
