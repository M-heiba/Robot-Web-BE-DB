*** Settings ***
Documentation    Keywords related to Login APIs
      
Library  RequestsLibrary 
Library  Process
Library  String
Library  OperatingSystem
Library  Collections
Library  BuiltIn

Resource    ../Common.robot        
                
*** Variables ***

&{headers}         content-type=application/json; application/x-www-form-urlencoded; charset=UTF-8   
...                Authorization=token    #content-type=application/json; ; application/x-www-form-urlencoded; charset=UTF-8

*** Keywords ***

Login with credentials
    [Arguments]    ${UserEmail}      ${Password}
    ${data}    BuiltIn.Set Variable    grant_type=password&password=${Password}&username=${UserEmail} 
    Log      ${data}          #console=${True}
    ${resp}  RequestsLibrary.Post Request    Application_session    /auth/token    params=${data}         headers=${headers}        
    # BuiltIn.Set global Variable   ${resp} 
    log      Request response ${resp.status_code}      #console=${True}
    # log      ${resp.text}     console=${True}
    log      ${resp.json()}   #console=${True}
    [Return]    ${resp}    

Verify Invalid credentials reponse is received
    [Arguments]    ${resp}
    BuiltIn.Should Be Equal As Strings            ${resp.status_code}    400
    ${ResponseJson}    BuiltIn.Set Variable       ${resp.json()}    
    Collections.Dictionary Should Contain Item    ${ResponseJson}    error                invalid_credentials     
    
        