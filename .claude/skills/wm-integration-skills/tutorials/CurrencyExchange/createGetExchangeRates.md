Please generate the FSL code for the following service based on the catalog mapping rules provided in the system instructions:

### Service Definition & Properties
* **Interface Name:** exchange
* **Service Name:** GetExchangeRates
* **Description:** This service retrieves a list of current foreign exchange rates relative to a specified anchor currency, defaulting to USD if no base currency is provided. It allows users to optionally filter the results down to a single destination currency or return the entire collection of available currency pairs. The resulting data set is returned as a structured document list designed for seamless downstream mapping and conversions.

Strictly apply the following structural rules when generating the code:
- Include full inline properties (`required: false`) for all inputs, outputs, and the main service.
- Do not include any comments.
- Use explicit data transformation steps to modify strings instead of using direct text macro line assignments.
- Set input and output validation settings to false on all invoked operations.

The service needs two optional text inputs:
- 'baseCurrency': required=false.
- 'targetCurrency': required=false.

It should output a document list called 'exchangeRates' with unspecified fields allowed.

Implement the service logic step-by-step:
1. If 'baseCurrency' is null, use a data mapping step to initialize it to "USD".
2. Initialize a text variable named `baseUrl` to "https://api.frankfurter.dev/v2/rates".
3. Use a string concatenation transformation step to join `baseUrl` with the text literal "?base=%baseCurrency%", saving the result back to `baseUrl`.
4. If 'targetCurrency' is not null, use a conditional string concatenation transformation step to append "&quotes=%targetCurrency%" to `baseUrl`.
5. Issue an HTTP GET request using `baseUrl` as the request URL.
6. Convert the resulting response body bytes into a text string variable named `output`.
7. Parse that `output` text string from JSON format into a structured document, mapping it directly to the final 'exchangeRates' output document list.
8. Within that final parsing step, explicitly drop all intermediate pipeline variables (`jsonString`, `bytes`, `url`, `method`, `output`, `baseUrl`, `encodedURL`, `header`, `body`, `string`, `document`) to clean up the workspace memory.
