# openAI-coldfusion-utils
A series of utility components for working with the OpenAI API from CFML. These components currently focus on working with [Assistants](https://platform.openai.com/docs/assistants/overview) in the OpenAI API.

---

### What You'll Need

- An account with [OpenAI](https://platform.openAI.com)
- An [assistant](https://platform.openai.com/docs/assistants/overview) and the corresponding assistant ID to work with. These utilities do not create assistants.
- A [project-based API key](https://platform.openai.com/api-keys) in the same project as your assistant.

This is not perfect code. You will absolutely want to figure out a different way to pass your OpenAI API key into the ```openAIAssistantsHTTPRequest``` component.

### What Each File Does

- ```openAIAssistantsHTTPRequest.cfc``` : handles underlying ```cfhttp``` requests to the OpenAI API.
- ```openAIFileManager.cfc``` : handles adding and removing files and vector stores in the OpenAI API.
- ```openAIThreadRunManager.cfc``` : handles creating threads, messages, and runs in the OpenAI API.

### Want to Contribute?

Please make a pull request!