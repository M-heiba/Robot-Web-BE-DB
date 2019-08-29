*** Settings ***
Documentation    All components related to Homepage

Library  SeleniumLibrary
Library  Process
Library  String
Library  OperatingSystem
Library  Collections
Library  BuiltIn

Resource    ../Common.robot

*** Variables ***


*** Keywords ***

Verify HomePage is loaded
    SeleniumLibrary.Location Should Contain    Homepage
    

