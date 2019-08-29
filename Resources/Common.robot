*** Settings ***
Documentation  This file for common keywords of the project

Library  SeleniumLibrary
Library  Process
Library  String
Library  OperatingSystem
Library  Collections
Library  BuiltIn
Library    DateTime    
Library    DatabaseLibrary
Library    RequestsLibrary    

Resource    PageObject/HomePage.robot

*** Variables ***

###################################  Credentials #####################################################

${Admin_UserEmail}    admin@domain.com
${Admin_Password}     Password 

#################################### Frontend Vars ####################################################

${URL}          http://127.0.0.1        #http://clearview.ole-lab.com                
${Browser}      firefox
${Mode}         GUI                    # Options : GUI , HeadlessChrome , HeadlessFirefox , Remote
${remote_url}   Not set yet

################################### Backend Vars ######################################################

${Base_url}        http://127.0.0.1:8888
&{headers}         content-type=application/json; application/x-www-form-urlencoded;  charset=UTF-8   Authorization=token    

##content-type=application/json; ; application/x-www-form-urlencoded; charset=UTF-8
# &{Params}          grant_type=password    password=w    username=ww

################################### Database Vars ####################################################

${DB_username}        Username 
${DB_Password}        Password 
${DB_schema_Name}     Schema 
${DB_HostUrl}         127.0.0.1   
${DB_HostPort}        8282
${DB_module}          pymysql    #MySQLdb    #pyodbc


*** Keywords ***

################################### Front END  #######################################################

################### Test Setup ########################

open application website
    Open webbrowser
    Go To    ${URL}
    Verify HomePage is loaded

Open webbrowser
    run keyword if  '${Mode}' == 'GUI'               Normal GUI
    run keyword if  '${Mode}' == 'HeadlessChrome'    HeadlessChrome
    run keyword if  '${Mode}' == 'HeadlessFirefox'   HeadlessFirefox
    run keyword if  '${Mode}' == 'Remote'            Remote
    BuiltIn.Set Log Level    DEBUG
    
    ##############  Headless chrome option ##############
    
HeadlessChrome
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    headless
    Call Method    ${chrome_options}    add_argument    disable-gpu
    # Call Method    ${chrome_options}    add_argument    window-size=1920,1080
    Create Webdriver    Chrome    chrome_options=${chrome_options}
    Set Browser Implicit Wait    15s

    ##############  Headless Firefox option ##############
    
HeadlessFirefox
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].FirefoxOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    -headless
    Create Webdriver    Firefox    firefox_options=${options}
    Set Browser Implicit Wait    10s

    #############  Normal GUI  ####################
    
Normal GUI
    Open Browser   about:blank     ${Browser}
    Set Browser Implicit Wait    10s
    Maximize Browser Window

    #############  Remote Headless chrome ###############
    
Remote
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    headless
    Call Method    ${chrome_options}    add_argument    disable-gpu
    Open Browser    ${url}    Chrome    remote_url=${remote_url}    desired_capabilities=${chrome_options.to_capabilities()}


################### Test Teardown ########################  

Close webbrowsers
    Close all browsers

Reset browser session 
    SeleniumLibrary.Delete All Cookies
   
################################### Back END  ########################################################

Create Application API session
    RequestsLibrary.Create Session     Application_session    ${Base_url}
    log            Session Created     #console=${True}
    BuiltIn.Set Log Level    Debug

################################### Database  ########################################################

Connect to Application MySQL database
    [Documentation]    Connecting to MySQL instance with clearView data
    Connect To Database    dbapiModuleName=${DB_module}  dbName=${DB_schema_Name}     dbUsername=${DB_username}    
    ...                    dbPassword=${DB_Password}     dbHost=${DB_HostUrl}         dbPort=${DB_HostPort}    
    ...                    #dbCharset=None  dbConfigFile=./resources/db.cfg
        
Query Application MySQL database    
    [Arguments]    ${Query_string}
    @{Result}  Query    ${Query_string}    returnAsDict=True     
    # Log   ${Result[0]['column01']}
    [Return]    ${Result}    
    
Disconnect Application database    
    DatabaseLibrary.Disconnect From Database


################################### Utils ############################################################

Scroll down
    execute javascript  window.scrollBy(0,600)

Javascript scroll element into view by Xpath
    [Arguments]    ${locator}
    ${Firstpart}   ${xpath}     String.Split String    ${locator}    separator==    max_split=1
    SeleniumLibrary.Execute Javascript    var ScrollingElement = document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; ScrollingElement.scrollIntoView();
   

Get data from csv data file
    [Arguments]   ${PathToDataFile}
    
    #reading Data file and return values to dictionary
    log    ${PathToDataFile}
    ${File_contents}    OperatingSystem.Get File    ${PathToDataFile}         
    Log   ${File_contents}    
    
    @{Lines}    String.Split To Lines    ${File_contents}
    Collections.Log List   ${Lines}
    
    &{Data_dictionary}  BuiltIn.Create Dictionary
    :FOR    ${LINE}    IN    @{Lines}
    \    Log    ${LINE}
    \    @{COLUMNS}     Split String     ${LINE}    separator=,
    \    Collections.Set To Dictionary    ${Data_dictionary}     @{COLUMNS}[0]     @{COLUMNS}[1] 
    \    Collections.Log Dictionary    ${Data_dictionary}      
    
    Collections.Log Dictionary    ${Data_dictionary}  
    
    [Return]    ${Data_dictionary}  
    
#  Commands to run in case of virtual enviroment existing
#  venv/scripts/activate    to switch to venv in folder
#  Robot -d results/demo -i tags tests
