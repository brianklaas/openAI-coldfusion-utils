/*
* @name: openAIFileManager
* @hint: Handles working with files and vector stores in the OpenAI API
* @author: Brian Klaas 
* @created: 06/20/2024
*/

component
	displayname="openAIFileManager"
	output="false"
	accessors="true"
{
    
    public openAIFileManager function init(
        required openAIAssistantsHTTPRequest assistantsHttpRequestService
    ) {
        variables.openAIAssistantsHTTPRequestService = arguments.assistantsHttpRequestService;
        writeLog(file="componentInitLog", text="init openAI.openAIFileManager");
		return this;
	}

    /*
	* @name:	uploadFile
	* @hint:	Uploads a file to the OpenAI file store
	* @returns:	Struct of information about the uploaded file, including the fileID
	* @author:  Brian Klaas 
	* @created: 06/21/2024
	*/
    public struct function uploadFile(
        required string pathToFile
	) {
        var returnStruct = {};
        var filePath = expandPath(arguments.pathToFile);
        writeLog(file="openAIAssistantsAPIRequests", text="File path is #filePath#");

        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST","files", filePath, 1);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
        } else {
            returnStruct = {
                "success" = 1,
                "fileID" = openAIResponse.callResult.id
            };
        }
        return returnStruct;
    }

    /*
	* @name:	createVectorStore
	* @hint:	Creates a vector store in the OpenAI file store
	* @returns:	Struct of information about newly created vector store, including the vectorStoreID
	* @author:  Brian Klaas 
	* @created: 06/21/2024
	*/
    public struct function createVectorStore() {
        var returnStruct = {};
        var thisRequestBody = {
            "name" = dateTimeFormat(now(), "long"),
            "expires_after" = {
                "anchor" = "last_active_at",
	            "days" =3
            }
        };
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST","vector_stores", thisRequestBody);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
        } else {
            returnStruct = {
                "success" = 1,
                "vectorStoreID" = openAIResponse.callResult.id
            };
        }
        return returnStruct;
    }

    /*
	* @name:	addFileToVectorStore
	* @hint:	Adds a file uploaded to OpenAI to a vector store
	* @returns:	Struct of information about the request
	* @author:  Brian Klaas 
	* @created: 06/22/2024
	*/
    public struct function addFileToVectorStore(
        required string fileID,
        required string vectorStoreID
    ) {
        var returnStruct = {};
        var requestPath = "vector_stores/" & arguments.vectorStoreID & "/files";
        var thisRequestBody = {
            "file_id" = arguments.fileID
        };
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("POST", requestPath, thisRequestBody);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
        } else {
            returnStruct = {
                "success" = 1
            };
        }
        return returnStruct;
    }

    /*
	* @name:	hasFileBeenProcessed
	* @hint:	Checks to see if the specified file in the specified vector store has been processed
	* @returns:	Boolean indicating if the files was processed
	* @author:  Brian Klaas 
	* @created: 06/22/2024
	*/
    public boolean function hasFileBeenProcessed(
        required string fileID,    
        required string vectorStoreID
	) {
        var returnVal = 0;
        var requestPath = "vector_stores/" & arguments.vectorStoreID & "/files/" & arguments.fileID;
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("GET", requestPath);
        if (openAIResponse.errorFlag eq 0) {
            if (openAIResponse.callResult.status is "completed") {
                returnVal = 1;
            }
        }
        return returnVal;
    }

    /*
	* @name:	deleteFile
	* @hint:	Deletes a file uploaded to OpenAI
	* @returns:	Struct of information about the request
	* @author:  Brian Klaas 
	* @created: 06/25/2024
	*/
    public struct function deleteFile(
        required string fileID
    ) {
        var returnStruct = {};
        var requestPath = "files/" & arguments.fileID;
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("DELETE", requestPath);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
        } else {
            returnStruct = {
                "success" = 1
            };
        }
        return returnStruct;
    }

    /*
	* @name:	deleteVectorStore
	* @hint:	Deletes a vector store from OpenAI
	* @returns:	Struct of information about the request
	* @author:  Brian Klaas 
	* @created: 06/25/2024
	*/
    public struct function deleteVectorStore(
        required string vectorStoreID
    ) {
        var returnStruct = {};
        var requestPath = "vector_stores/" & arguments.vectorStoreID;
        var openAIResponse = variables.openAIAssistantsHTTPRequestService.makeOpenAIAssistantsAPIRequest("DELETE", requestPath);
        if (openAIResponse.errorFlag eq 1) {
            returnStruct.success = 0;
            returnStruct.rawResponse = openAIResponse.rawResponse;
            returnStruct.callingArgs = arguments;
        } else {
            returnStruct = {
                "success" = 1
            };
        }
        return returnStruct;
    }

}