/*
* @name: openAIThreadRunManager
* @hint: Handles working with threads and runs in the OpenAI API
* @author: Brian Klaas (bklaas@jhu.edu)
* @created: 06/24/2024
*/

component
	displayname="openAIThreadRunManager"
	output="false"
	accessors="true"
{
    
    public openAIThreadRunManager function init(
        required openAIAssistantsHTTPRequest assistantsHttpRequestService
    ) {
        variables.openAIAssistantsHTTPRequestService = arguments.assistantsHttpRequestService;
        writeLog(file="componentInitLog", text="init openAI.openAIThreadRunManager");
		return this;
	}

    /*
	* @name:	createThread
	* @hint:	Creates a thread in the OpenAI API
	* @returns:	Struct of information about the new thread, including the threadID
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/24/2024
	*/
    public struct function createThread(
        string vectorStoreID = ""
	) {
        var returnStruct = {};
        var requestPath = "threads";
        var thisRequestBody = {};
        var openAIResponse = {};
        if (len(trim(arguments.vectorStoreID))) {
            thisRequestBody = {
                "tool_resources" = {
                    "file_search" = {
                        "vector_store_ids" = ["#arguments.vectorStoreID#"]
                    }     
                }
            };
        }
        if (NOT structIsEmpty(thisRequestBody)) {
            openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST", requestPath, thisRequestBody);
        } else {
            openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST", requestPath);
        }
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
            return returnStruct;
        } else {
            returnStruct = {
                "success": 1,
                "threadID": openAIResponse.callResult.id
            };
        }
        return returnStruct;
    }

    /*
	* @name:	createMessageInThread
	* @hint:	Creates a message in an exsiting thread in the OpenAI API
	* @returns:	Struct of information about the new message, including the messageID
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/24/2024
	*/
    public struct function createMessageInThread(
        required string threadID,
        required string messageBody
	) {
        var returnStruct = {};
        var requestPath = "threads/" & arguments.threadID & "/messages";
        var thisRequestBody = {
            "role" = "user",
            "content" = arguments.messageBody
        };
        var openAIResponse = {};
        openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST", requestPath, thisRequestBody);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
            return returnStruct;
        } else {
            returnStruct = {
                "success": 1,
                "threadID": openAIResponse.callResult.id
            };
        }
        return returnStruct;
    }

    /*
	* @name:	createRun
	* @hint:	Creates a run in an exsiting thread in the OpenAI API
	* @returns:	Struct of information about the new run, including the runID
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/24/2024
	*/
    public struct function createRun(
        required string threadID,
        required string assistantID
	) {
        var returnStruct = {};
        var requestPath = "threads/" & arguments.threadID & "/runs";
        var thisRequestBody = {
            "assistant_id" = arguments.assistantID
        };
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST", requestPath, thisRequestBody);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
            return returnStruct;
        } else {
            returnStruct = {
                "success": 1,
                "runID": openAIResponse.callResult.id
            };
        }
        return returnStruct;
    }

    /*
	* @name:	isRunComplete
	* @hint:	Checks to see if the specified run has finished
	* @returns:	Value indicating if the run is complete: 0 = no, 1 = yes, 2 = failed
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/24/2024
	*/
    public numeric function isRunComplete(
        required string threadID,
        required string runID
	) {
        var returnVal = 0;
        var requestPath = "threads/" & arguments.threadID & "/runs/" & arguments.runID;
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("GET", requestPath);
        if (openAIResponse.errorFlag eq 0) {
            if (openAIResponse.callResult.status is "completed") {
                returnVal = 1;
            } else if (structKeyExists(openAIResponse.callResult, "failed_at") && (openAIResponse.callResult.failed_at neq "null")) {
                returnVal = 2;
            }
        }
        return returnVal;
    }
 
    /*
	* @name:	getRunContent
	* @hint:	Gets the contnet for a completed run on an exsiting thread in the OpenAI API
	* @returns:	Struct of information about the new run, including the generated content
	* @author:  Brian Klaas (bklaas@jhu.edu)
	* @created: 06/24/2024
	*/
    public struct function getRunContent(
        required string threadID
	) {
        var returnStruct = {};
        var requestPath = "threads/" & arguments.threadID & "/messages";
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("GET", requestPath);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
            return returnStruct;
        } else {
            // This returns the first response in the "data" array. If you have a multi-step conversation, you'll need to select the appropriate response from the array.
            returnStruct = {
                "success": 1,
                "generatedContent": openAIResponse.callResult.data[1].content[1].text.value
            };
        }
        return returnStruct;
    }
}