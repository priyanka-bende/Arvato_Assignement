*** Settings ***
     
Library    RequestsLibrary 
Library    OperatingSystem  
Library    JSONLibrary   
Library    String    
Library    Collections    
Resource    resources/API_Resource.robot
Resource    resources/Configuration.resource



*** Variables ***
${response_json}

*** Test Cases ***

 
Scenario1:Verify the response code as 200 and data in output json
      [Documentation]     Given From Currency is Nok To currency is EUR then calculate the Currency
    ...     when exchage rate is received
    ...    then verify the response code
     #BuiltIn.Set Global Variable    ${response}        
     ${response_fixer}    API_Resource.Hit fixed api    ${to_currency}
    ${exchange_rate}    API_Resource.Fetch exchange rate from fixer     ${response_fixer}     ${to_currency}
   
    ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${to_currency}    ${amount}   
    API_Resource.validate status code for response    ${api_response}    200
    API_Resource.validate json response parameter    ${api_response}
    API_Resource.check values in response json    ${api_response}     ${from_currency}     ${to_currency}    ${amount}    ${exchange_rate}
    API_Resource.calculate the amount for to currency    ${api_response}    ${amount}
Scenario2:Verify the response code as 400 and If mandatory parameter From Currency is missing
       [Documentation]     Given  To currency is missing 
    ...     when From Currency is EUR
    ...    then validate the response Code
     ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}   ""    ${amount}
     API_Resource.validate status code for response    ${api_response}    400
     API_Resource.validate error message    ${api_response}    ${invalid_currency_err_msg}    ${Error_code}   
 
Scenario3:Verify the response code as 404 and If mandatory parameter Amount is incorrect
       [Documentation]     Given  To currency is missing 
    ...     when From Currency is EUR
    ...    then validate the response Code
      ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${from_currency}   "yyyy"
     API_Resource.validate status code for response    ${api_response}    404

Scenario4:Verify If To currency is an invalid currency
          [Documentation]     Given  To currency is an invalid currency
    ...     when From Currency is EUR
    ...    then validate the response Code as 400    
     ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${invalid_curr}   ${amount}
     API_Resource.validate status code for response    ${api_response}    400
     API_Resource.validate error message    ${api_response}    ${Err_Missing_Curr}    ${error_code_invalid_code}
Scenario5:Verify the response code and error message If Amount is 0
              [Documentation]     Given  Amount is 0
    ...     when From Currency  and To Currency is Valid
    ...    then validate the response Code as 400 and error message   
     
      ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${to_currency}    0 
     API_Resource.validate status code for response    ${api_response}    400
     API_Resource.validate error message    ${api_response}    ${Err_msg_amount}    ${error_invalid_input}

Scenario6:Validate the response if to currency is provided in small letter
                  [Documentation]     Given a valid to currency is provided in small letters
    ...     when  To Currency is Valid
    ...    then validate the response Code as 400 and error message  
       ${response_fixer}    API_Resource.Hit fixed api    ${to_currency}
       ${exchange_rate}    API_Resource.Fetch exchange rate from fixer     ${response_fixer}     ${to_currency}
       
      ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${to_currency_small_letter}    ${amount}   
      API_Resource.validate status code for response    ${api_response}    200
     
     API_Resource.validate json response parameter    ${api_response}
     API_Resource.check values in response json    ${api_response}     ${from_currency}     ${to_currency_small_letter}    ${amount}    ${exchange_rate}
     API_Resource.calculate the amount for to currency    ${api_response}    ${amount}
     
     #API_Resource.validate error message    ${response}    ${Err_msg_amount}    ${Error_code}
Scenario7:Verify If To currency is in invalid pattern
          [Documentation]     Given  To currency is an invalid currency
    ...     when From Currency is EUR
    ...    then validate the response Code as 400    
     ${api_response}    API_Resource.Hit the URI and get the reponse    ${End_point}    ${invalid_pattern_currency}   ${amount}  
     API_Resource.validate status code for response    ${api_response}    400
     API_Resource.validate error message    ${api_response}       ${error_currency_length}    ${error_invalid_input}
   
*** Keywords **

# Get response from API when To Currency is NOK
    # ${response}    API_Resource.Hit the URI and get the reponse
    # API_Resource.validate json response parameter    ${response}
    # [Return]    ${response}    
# validate the value in output json
    # [Arguments]    ${response}     
    # check data in response data    ${response} 
# validate the calculation of conversion
    # [Arguments]    ${response}
    # API_Resource.calculate the amount for to currency    ${response}
    
    
        


