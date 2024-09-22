/*
* @name: openAIAssistantsHTTPRequest
* @hint: Handles generating HTTP requests to the OpenAI API
* @author: Brian Klaas (bklaas@jhu.edu)
* @created: 06/06/2024
*/

component
	displayname="openAIAssistantsHTTPRequest"
	output="false"
	accessors="true"
{
    
    public openAIAssistantsHTTPRequest function init() {
    	// You really don't want to hard-code this in your production code.
        variables.openAIAuthHeader = "Bearer YOUR API TOKEN HERE";
        variables.openAIAPIBasePath = "https://api.openai.com/v1/";
        writeLog(file="componentInitLog", text="init openAI.openAIAssistantsHTTPRequest");
		return this;
	}

    /*
	* @name:	makeOpenAIAssistantsAPIRequest
	* @hint:	Wrapper for making requests to the OpenAI Assistants API via https
	* @returns:	A JSON result string
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/06/2024
	*/
    public struct function makeOpenAIAssistantsAPIRequest(
		required string method = "GET",
		required string apiPath,
	    string requestBody,
        boolean directFileUpload = 0
	) {
        var returnStruct = {
            errorFlag = 0,
            callResult = {},
            rawResponse = {},
            callingArgs = arguments
        };
        var result = "";
        var fullOpenAIAPIPath = variables.openAIAPIBasePath & arguments.apiPath;
        writeLog(file="openAIAssistantsAPIRequests", text="Making #arguments.method# call to #fullOpenAIAPIPath#");
        try {
            if (structKeyExists(arguments, "requestBody") && (len(arguments.requestBody) GT 1)) {
                writeLog(file="openAIAssistantsAPIRequests", text="Request body: #arguments.requestBody# ;; directFileUpload = #arguments.directFileUpload#");
                if (NOT arguments.directFileUpload) {
                    cfhttp(method=arguments.method, charset="utf-8", url=fullOpenAIAPIPath, result="result") {
                        cfhttpparam(name="Authorization", type="header", value=variables.openAIAuthHeader);
                        cfhttpparam(name="OpenAI-Beta", type="header", value="assistants=v2");
                        cfhttpparam(name="content-type", type="header", value="application/json");
                        cfhttpparam(type="body", value="#arguments.requestBody#");
                    }
                } else {
                    cfhttp(method=arguments.method, charset="utf-8", url=fullOpenAIAPIPath, result="result") {
                        cfhttpparam(name="Authorization", type="header", value=variables.openAIAuthHeader);
                        cfhttpparam(name="OpenAI-Beta", type="header", value="assistants=v2");
                        cfhttpparam(name="purpose", type="formfield", value="assistants");
                        cfhttpparam(type="file", file="#arguments.requestBody#", name="file");
                    }
                }
            } else {
                cfhttp(method=arguments.method, charset="utf-8", url=fullOpenAIAPIPath, result="result") {
                    cfhttpparam(name="Authorization", type="header", value=variables.openAIAuthHeader);
                    cfhttpparam(name="OpenAI-Beta", type="header", value="assistants=v2");
                    cfhttpparam(name="content-type", type="header", value="application/json");
                }
            }
        } catch (any e) {
            writeLog(file="openAIAssistantsAPIRequests", text="Failed call to #fullOpenAIAPIPath# -- #e.message#: #e.Detail# #SerializeJSON(e.tagcontext[1])#");
            returnStruct.errorFlag = 1;
            returnStruct.apiRequestFail = 1;
            returnStruct.cfcatchInfo = e;
            return returnStruct;
        }
        returnStruct.rawResponse = result;
        // Successful requests should all begin with a 2xx result
        if (left(result.statusCode, 1) EQ 2) {
            if ((structKeyExists(result, "fileContent")) && (isJSON(result.fileContent))) {
                returnStruct.callResult = deserializeJSON(result.fileContent);
            }
            writeLog(file="openAIAssistantsAPIRequests", text="Successful call to #fullOpenAIAPIPath#");
        } else {
            writeLog(file="openAIAssistantsAPIRequests", text="Error on #arguments.method# call to #fullOpenAIAPIPath# ;; Satus Code = #result.statuscode#");
            if ((structKeyExists(result, "fileContent")) && (isJSON(result.fileContent))) {
                writeLog(file="openAIAssistantsAPIRequests", text="Faild call result: #result.fileContent#");
            }
            returnStruct.errorFlag = 1;
        }
        return returnStruct;
    }

}