# 💡 EXAMPLES
The following examples will create proper FSL. Take note of the user prompts. You may get prompted in a similar manner.
If after reviewing these examples, you are unsure how to generate the FSL for a given prompt, refer to the examples in the directory: `skills/flow/examples`. But only go there after you have reviewed all of the examples in this document.

## EXAMPLE 1: COMPLEX SIGNATURE (LISTS AND OBJECTS)
**User:** 'Create processOrder in orders.receive with input customerType as string and priceList as double list. Map status to "PENDING".'

    service processOrder (
        input {
            String customerType;
            Double[] priceList;
        }
        output {
            String status;
        }
    )
    {
        MAP {
            mapTarget {
                String status;
            }
            set status = "PENDING";
        }
    }

## EXAMPLE 2: INVOKE WITH NO MAPPING (STRICT ADHERENCE)
**User:** 'Invoke pub.math:addObjects but do not map any fields.'

    INVOKE pub.math:addObjects {}

## EXAMPLE 3: MULTI-INPUT MAPPING WITH TYPE PRESERVATION
**User:** 'Add orderTotal and lineTotal using pub.math:addInts mapping orderTotal to num1 and lineTotal to num2. Map the output from pub.math:addInts, value, to orderTotal.'
**Note:** The mapTarget types (Integer num1, Integer num2) match what pub.math:addInts expects as input parameters. The mapSource types (Integer orderTotal, Integer lineTotal) reflect the actual pipeline variables being mapped.

    INVOKE addInts {
        input {
            mapSource {
                Integer orderTotal;
                Integer lineTotal;
            }
            mapTarget {
                Integer num1;
                Integer num2;
            }
            copy orderTotal -> num1;
            copy lineTotal -> num2;
        }
        output {
            mapSource {
                Integer `value`;
            }
            mapTarget {
                Integer orderTotal;
            }
            copy `value` -> orderTotal;
        }
    }

## EXAMPLE 4: IF/ELSE WITH STRING LITERALS
**User:** 'If status is NEW then invoke myService.'

    IF (%status% == "NEW") {
        INVOKE myService {}
    }

## EXAMPLE 5: LOOP OVER ARRAY (STRICT FSL)
**User:** 'Loop over items and invoke pub.math:multiplyObjects.'

    LOOP {
        inputArray: "/items"
        INVOKE pub.math:multiplyObjects {}
    }

## EXAMPLE 6: LOOP WITH MAPPED INVOKE
**User:** 'Loop over items and multiply price by quantity using pub.math:multiplyObjects.'

    LOOP {
        inputArray: "/items"
        INVOKE pub.math:multiplyObjects {
            input {
                mapSource {
                    record items {
                        String price;
                        String quantity;
                    };
                }
                mapTarget {
                    String num1;
                    String num2;
                }
                copy items/price -> num1;
                copy items/quantity -> num2;
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    Double lineTotal;
                }
                copy `value` -> lineTotal;
            }
        }
    }

## EXAMPLE 7: TYPE PRESERVATION IN INVOKE MAPPINGS
**User:** 'Invoke pub.math:multiplyObjects mapping quantity (Integer) to num1 and price (Double) to num2.'
**Note:** The mapTarget types must match what the invoked service expects. In this example, pub.math:multiplyObjects expects numeric inputs, so we use Integer for num1 (matching quantity) and Double for num2 (matching price). Never default to String for numeric mappings.

    INVOKE pub.math:multiplyObjects {
        input {
            mapSource {
                Integer quantity;
                Double price;
            }
            mapTarget {
                Integer num1;
                Double num2;
            }
            copy quantity -> num1;
            copy price -> num2;
        }
        output {
            mapSource {
                Double `value`;
            }
            mapTarget {
                Double result;
            }
            copy `value` -> result;
        }
    }

## EXAMPLE 8: CREATING NEW TYPED VARIABLES IN A MAP
**User:** 'Create service calc. In a MAP, set new field rates to a double list of 0.05.'

    service calc (
        output {
            Double[] rates;
        }
    )
    {
        MAP {
            mapTarget {
                Double[] rates;
            }
            set rates = ["0.05", "0.06", "0.07"];
        }
    }

## EXAMPLE 9: MULTI-BRANCH IF/ELSEIF
**User:** 'If status is NEW then invoke S1, else if status is PENDING then invoke S2, else invoke S3.'

    IF (%status% == "NEW") {
        INVOKE S1 {}
    }
    ELSEIF (%status% == "PENDING") {
        INVOKE S2 {}
    }
    ELSE {
        INVOKE S3 {}
    }

## EXAMPLE 10: SWITCH AND CASE
**User:** 'Switch on customerType. Case "VIP": invoke S1. Case "DEFAULT": invoke S2.'

    SWITCH (customerType) {
        CASE "VIP" :
            INVOKE S1 {}
        CASE "$default" :
            INVOKE S2 {}
    }

**⚠️ SWITCH syntax rules (critical):**
- Switch expression: bare variable name — NO `%` signs, NO quotes, NO path notation.
    - CORRECT: `SWITCH (customerType)`
    - INCORRECT: `SWITCH (%customerType%)`, `SWITCH ("/customerType")`
- Each `CASE` arm owns exactly ONE direct child. For multiple steps, wrap in `SEQUENCE`:

    SWITCH (operation) {
        CASE "add" :
            SEQUENCE {
                INVOKE pub.flow:debugLog {}
                INVOKE pub.math:addInts {}
            }
        CASE "$default" :
            EXIT { exitFrom: "$flow" signal: "FAILURE" failureMessage: "Invalid operation" }
    }

**BRANCH (alternative):** Use `BRANCH` with `switch: "/path"` and `SEQUENCE { label: "value" }` when you need path notation or label evaluation. `SWITCH` and `BRANCH` are different constructs — do not mix their syntax.

## EXAMPLE 11: DO-UNTIL LOOP (REPEAT)
**User:** "Do a loop where I map count = 1 until count is 10."

    DO {
        maxIteration: 10
        MAP {
            mapTarget {
                String count;
            }
            set count = "1";
        }
    } UNTIL (%count% == 10)

## EXAMPLE 12: SETTING INTEGERS IN A MAP
**User:** "In a MAP step, set integer X to 0 and integer one to 1."

    MAP {
        mapTarget {
            Integer X;
            Integer one;
        }
        set X = 0;
        set one = 1;
    }

## EXAMPLE 13: WHILE LOOP WITH INCREMENT
**User:** "Start a WHILE loop for Y < 11. Inside the loop, invoke myService and increment Y."
**Note:** This example shows `maxIteration` for demonstration. Do NOT include it unless explicitly requested.

    WHILE (%Y% < 11) {
        INVOKE myService {}
        MAP {
            TRANSFORM pub.math:addInts {
                input {
                    mapSource {
                        Integer Y;
                    }
                    mapTarget {
                        Integer num1;
                        Integer num2;
                    }
                    copy Y -> num1;
                    set num2 = 1;
                }
                output {
                    mapSource {
                        Integer `value`;
                    }
                    mapTarget {
                        Integer Y;
                    }
                    copy `value` -> Y;
                }
            }
        }
    }

## EXAMPLE 14: REPEAT LOOP WITH NESTED SEQUENCE
**User:** "Add a Do loop with a sequence containing the following steps until X is > 10: Invoke pub.math:addObjects linking X to num1 and one to num2 for the input, and the output links value to X."
**Note:** This example shows `maxIteration` for demonstration. Do NOT include it unless explicitly requested.

    DO {
        SEQUENCE {
            INVOKE pub.math:addObjects {
                input {
                    mapSource {
                        Integer X;
                        Integer one;
                    }
                    mapTarget {
                        Integer num1;
                        Integer num2;
                    }
                    copy X -> num1;
                    copy one -> num2;
                }
                output {
                    mapSource {
                        Integer `value`;
                    }
                    mapTarget {
                        Integer X;
                    }
                    copy `value` -> X;
                }
            }
        }
    } UNTIL (%X% > 10)

## EXAMPLE 15: NATURAL LANGUAGE STRING LISTS
**User:** 'Next I want a Map step that sets a string array called myCodes to "aaaaa", "bbbbb", "ccccc", "ddddd", "eeeee".'

    MAP {
        mapTarget {
            String[] myCodes;
        }
        set myCodes = ["aaaaa", "bbbbb", "ccccc", "ddddd", "eeeee"];
    }

## EXAMPLE 16: REPEAT/RETRY LOOP WITH DYNAMIC INDEXING
**User:** 'In the loop, map the current retry row of myList to targetField.'

    REPEAT {
        count: 5
        repeatInterval: 2
        repeatOn: "SUCCESS"
        MAP {
            TRANSFORM pub.string:concat {
                input {
                    mapSource {
                        String concatField;
                        String[] repeatVals;
                    }
                    mapTarget {
                        String inString1;
                        String inString2;
                    }
                    copy concatField -> inString1;
                    copy repeatVals[$retries] -> inString2;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String concatField;
                    }
                    copy `value` -> concatField;
                }
            }
        }
    }

## EXAMPLE 17: RETRY BLOCK (LOGIC BLOCK PATTERN)
**User:** 'Create a repeat loop that runs 5 times every 10 seconds if it fails. Inside, invoke myService.'

    REPEAT {
        count: 5
        repeatInterval: 10
        repeatOn: "FAILURE"
        INVOKE myService {}
    }

## EXAMPLE 18: TRY-CATCH
**User:** 'Add a try block. Inside, invoke S1. Then catch errors and invoke debugLog with message: "An error occurred".'

    TRY {
        INVOKE S1 {}
    }
    CATCH {
        INVOKE pub.flow:getLastError {
            output {
                mapSource {
                    record lastError;
                }
                mapTarget {
                    String errorMessage;
                }
                copy lastError/message -> errorMessage;
            }
        }
        INVOKE pub.flow:debugLog {
            input {
                mapSource {
                    String errorMessage;
                }
                mapTarget {
                    String `message`;
                }
                copy errorMessage -> `message`;
            }
        }
    }

## EXAMPLE 19: TRY-FINALLY
**User:** 'Add a try block. Inside, invoke S1. Finally invoke debugLog with message: "Completion of the try".'

    TRY {
        INVOKE S1 {}
    }
    FINALLY {
        INVOKE pub.flow:debugLog {
            input {
                mapTarget {
                    String `message`;
                }
                set `message` = "Completion of the try";
            }
        }
    }

## EXAMPLE 20: TRY-CATCH-FINALLY
**User:** 'Add a try block. Inside, invoke S1. Then catch errors and invoke debugLog with message: "An error occurred". Finally invoke debugLog with message: "Completion of the try".'

    TRY {
        INVOKE S1 {}
    }
    CATCH {
        INVOKE pub.flow:debugLog {
            input {
                mapTarget {
                    String `message`;
                }
                set `message` = "An error occurred";
            }
        }
    }
    FINALLY {
        INVOKE pub.flow:debugLog {
            input {
                mapTarget {
                    String `message`;
                }
                set `message` = "Completion of the try";
            }
        }
    }

## EXAMPLE 21: TRANSFORMER WITH LINK AND VALUE
**User:** 'Create a MAP step that uses a transformer for pub.string:concat. Link the variable message from the pipeline input to the transformer's inString1 input. Set the value of the transformer's inString2 input to the literal string: "___Finished with DivideByZero". Map the transformer's value in the transformer's output to the message field in the pipeline output.'

    MAP {
        TRANSFORM pub.string:concat {
            input {
                mapSource {
                    String `message`;
                }
                mapTarget {
                    String inString1;
                    String inString2;
                }
                copy `message` -> inString1;
                set inString2 = "___Finished with DivideByZero";
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String `message`;
                }
                copy `value` -> `message`;
            }
        }
    }

## Add EXAMPLE 22: BRANCH (SWITCH MODE WITH NULL/DEFAULT)
**User:** 'Branch on customerId. If null invoke S1, if "ADMIN" invoke S2, otherwise invoke S3.'

    BRANCH {
        switch: "/customerId"
        evaluateLabels: false
        SEQUENCE {
            label: "$null"
            INVOKE S1 {}
        }
        SEQUENCE {
            label: "ADMIN"
            INVOKE S2 {}
        }
        SEQUENCE {
            label: "$default"
            INVOKE S3 {}
        }
    }

## Add EXAMPLE 23: BRANCH (EXPRESSION MODE WITH NULL CHECKS)
**User:** 'Add a branch. If price is > 100 and status is not null invoke S1. Otherwise, if status is null invoke S2.'

    BRANCH {
        evaluateLabels: true
        SEQUENCE {
            label: "%price% > 100 && %status% != $null"
            INVOKE S1 {}
        }
        SEQUENCE {
            label: "%status% == $null"
            INVOKE S2 {}
        }
    }

## Add EXAMPLE 24: BRANCH (HYBRID MODE - CONTEXT VARIABLE)
**User:** 'Branch on customerCode. If it starts with "VIP" invoke S1. If it is exactly "INTERNAL" invoke S2.'

    BRANCH {
        switch: "/customerCode"
        evaluateLabels: true
        SEQUENCE {
            label: "%customerCode% matches 'VIP.*'"
            INVOKE S1 {}
        }
        SEQUENCE {
            label: "%customerCode% == 'INTERNAL'"
            INVOKE S2 {}
        }
    }

## Add EXAMPLE 25: WHILE LOOP WITH NULL CHECK
**User:** 'While orderId is not null, invoke processOrder.'

    WHILE (%orderId% != $null) {
        maxIteration: 50
        INVOKE processOrder {
            input {
                mapSource {
                    String orderId;
                }
                mapTarget {
                    String orderId;
                }
                copy orderId -> orderId;
            }
        }
    }

## EXAMPLE 26: EXIT FROM FLOW
**User**: 'If status is ERROR, exit the flow.'

    IF (%status% == "ERROR") {
        EXIT {
            exitFrom: "$flow"
            comment: "Exiting flow due to error status"
        }
    }

## EXAMPLE 27: EXIT FROM LOOP (BREAK)
**User**: 'If item id is missing, break the loop.'

    LOOP { 
        inputArray: "/items"; 
    
        IF (%item/id% == $null) {
            BREAK
        }
    }

## EXAMPLE 28: EXIT FROM ITERATION (CONTINUE)
**User**: 'In the loop, if price is 0, skip to the next iteration.'

    LOOP { 
        inputArray: "/items"; 
    
        IF (%item/price% == 0) {
            CONTINUE
        }
        
        INVOKE processValidItem {}
    }

## EXAMPLE 29: EXIT FROM FLOW
**User**: 'If status is ERROR, exit the flow.'

    EXIT {
        exitFrom: "$flow"
    }

## EXAMPLE 30: SYSTEM VARIABLES IN CONDITIONS
**User**: 'In a DO loop, skip iteration 3 and break at iteration 5.'

    DO {
        SEQUENCE {
            IF (%$iterationCount% == 3) {
                CONTINUE
            }
            INVOKE processItem {}
            IF (%$iterationCount% >= 5) {
                BREAK
            }
        }
    } UNTIL (%counter% > 10)

    IF (%status% == "ERROR") {
        EXIT {
            exitFrom: "$flow"
            signal: "FAILURE"
            comment: "Exiting flow due to error status"
        }
    }

## EXAMPLE 31: BRANCH WITH EXPLICIT "DOES NOT EVALUATE"
**User:** 'Add a branch that switches on customerType and does not evaluate labels. If "VIP" invoke S1, if "STANDARD" invoke S2, otherwise invoke S3.'

    BRANCH {
        switch: "/customerType"
        evaluateLabels: false
        SEQUENCE {
            label: "VIP"
            INVOKE S1 {}
        }
        SEQUENCE {
            label: "STANDARD"
            INVOKE S2 {}
        }
        SEQUENCE {
            label: "$default"
            INVOKE S3 {}
        }
    }

## EXAMPLE 32: DROPS IN A MAP
**User:** 'Add a map and drop interestPct, interestRate, num2 and num1'

    MAP {
        drop `interestPct`;
        drop `interestRate`;
        drop `num2`;
        drop `num1`;
    }

## EXAMPLE 33: DROPS IN AN INVOKE
**User:** 'Divide the interestPct variable calculated in Step 1 by a hardcoded value of "12". Map the final output of this operation directly to the service output parameter monthlyInterest, and drop value'

    INVOKE pub.math:divideFloats {
        validateInput: false
        validateOutput: false
        input {
            copy `interestPct` -> `num1`;
            set `num2` = "12";
        }
        output {
            mapTarget {
                String monthlyInterest;
            }
            copy `value` -> `monthlyInterest`;
            drop `value`;
        }
    }

## EXAMPLE 34: NESTED DOCUMENT STRUCTURE IN MAPTARGET
**User:** 'Create a MAP step to initialize the field Field1 inside DocumentB, which is nested inside DocumentA, to the value "Active".'

    MAP {
        mapTarget {
            record DocumentA {
                record DocumentB {
                    String Field1;
                };
            };
        }
        set DocumentA/DocumentB/Field1 = "Active";
    }

## EXAMPLE 35: NESTED RECORD LIST STRUCTURE IN MAPTARGET
**User:** 'Add a MAP step that maps the transient pipeline variable oldField to a field named Deleteme inside the AmortizationScheduleAccum record list.'

    MAP {
        mapSource {
            String oldField;
        }
        mapTarget {
            recordList AmortizationScheduleAccum {
                String Deleteme;
            };
        }
        copy oldField -> AmortizationScheduleAccum/Deleteme;
    }

## EXAMPLE 36: RECORD REFERENCE SCHEMA RESOLUTION
**User:** 'Create a loop block containing a map target that defines a structured record row referencing the Loans:AmortizationSchedule blueprint.'

    WHILE (month < totalNumberOfPayments) {
        maxIteration: -1
        MAP {
            mapTarget {
                record AmortizationScheduleRow (Loans:AmortizationSchedule) {
                    allowUnspecifiedFields: true;
                } {
                    String paymentNumber;
                    String paymentAmount;
                    String interestAmount;
                    String principalAmount;
                    String endingBalance;
                };
            }
        }
    }

## EXAMPLE 37: STRUCTURAL ARRAY LITERAL INITIALIZATION
**User:** 'Create a map step establishing an accumulation array structure named AmortizationScheduleAccum as a recordList, initialized with an initial single element row containing Deleteme equal to "0".'

    MAP {
        mapTarget {
            recordList AmortizationScheduleAccum {
                String Deleteme;
            };
        }
        set AmortizationScheduleAccum = [{"Deleteme": "0"}];
    }

## EXAMPLE 38: EVALUATED LABEL BRANCHING AND CONDITIONAL SEQUENCES
**User:** 'Evaluate if tippingPointMonthHold == 1 AND monthlyPrincipalPaidHold > monthlyInterestOwedHold. If true, branch to check if iterationCountHold > 1. If verified, convert iterationCount to an Integer and save to tippingPointMonthHold.'

    BRANCH {
        evaluateLabels: true
        SEQUENCE {
            label: "%tippingPointMonthHold% == 1 && %monthlyPrincipalPaidHold% > %monthlyInterestOwedHold%"
            BRANCH {
                evaluateLabels: true
                MAP {
                    label: "%iterationCountHold% > 1"
                    TRANSFORM pub.math:toNumber {
                        input {
                            mapTarget {
                                String `num`;
                                String convertAs;
                            }
                            copy `$iterationCount` -> `num`;
                            set convertAs = "java.lang.Integer";
                        }
                        output {
                            mapSource {
                                String `num`;
                            }
                            mapTarget {
                                Integer tippingPointMonthHold;
                            }
                            copy `num` -> tippingPointMonthHold;
                        }
                    }
                }
            }
        }
    }

## EXAMPLE 39: TOP-LEVEL PROPERTIES
**User:** 'Create a private service called AmortizationCalculator with an input string loanAmount and output recordList AmortizationSchedule. Add a service description detailing that it calculates a monthly timeline schedule. Enable input validation.'

    interface Loans
    
    service AmortizationCalculator (
        input {
            String loanAmount;
        }
        output {
            recordList AmortizationSchedule;
        }
    )
    properties {
        comment: "Calculates the month-by-month repayment schedule of a loan based on the principal amount, interest rate, and loan length.";
        visible: private;
        validateInput: true;
        validateOutput: false;
    }
    {
        // Steps go here
    }

## EXAMPLE 40: COMPLEX RECORD WITH PROPERTIES AND LEAF FIELDS IN MAPPING PIPELINES
**User:** 'Map fields into an AmortizationScheduleRow record which references Loans:AmortizationSchedule and allows unspecified fields.'

    MAP {
        mapSource {
            String fixedMonthlyPayment;
        }
        mapTarget {
            record AmortizationScheduleRow (Loans:AmortizationSchedule) {
                allowUnspecifiedFields: true;
            } {
                String paymentNumber;
                String paymentAmount;
                String interestAmount;
                String principalAmount;
                String endingBalance;
            };
        }
        copy fixedMonthlyPayment -> AmortizationScheduleRow/paymentAmount;
    }

## EXAMPLE 41: RECORDLIST ACCUMULATOR PATTERN (SEED, APPEND, UNSEED)
**User:** 'Build an accumulator list called acceptedAccum. Initialize it with a seed record before a loop, append a record inside the loop using insertDocument, then remove the seed after the loop using deleteDocuments.'

    MAP {
        mapTarget {
            recordList acceptedAccum {
                String Deleteme;
            };
        }
        set acceptedAccum = [{"Deleteme": "0"}];
    }
    WHILE (%$iterationCount% < %totalRows%) {
        INVOKE pub.document:insertDocument {
            input {
                mapTarget {
                    recordList documents {
                        allowUnspecifiedFields: true;
                    };
                    record insertDocument {
                        allowUnspecifiedFields: true;
                    };
                }
                copy acceptedAccum -> documents;
                copy newRow -> insertDocument;
            }
            output {
                mapTarget {
                    recordList acceptedAccum {
                        allowUnspecifiedFields: true;
                    } {
                        String Deleteme;
                    };
                }
                copy `documents` -> `acceptedAccum`;
            }
        }
        MAP {
            drop `documents`;
        }
    }
    MAP {
        TRANSFORM pub.document:deleteDocuments {
            input {
                mapSource {
                    recordList acceptedAccum;
                }
                mapTarget {
                    String[] indices;
                    recordList documents;
                }
                set `indices` = ["0"];
                copy `acceptedAccum` -> `documents`;
            }
            output {
                mapSource {
                    recordList documents;
                }
                mapTarget {
                    recordList acceptedAccum;
                }
                copy `documents` -> `acceptedAccum`;
            }
        }
        drop `documents`;
    }

**Key rules for this pattern:**
- ALWAYS initialize with JSON array literal `set x = [{"Deleteme": "0"}]` — NEVER use `set x[0]/field = "value"` (creates IData, not IData[]).
- ALWAYS use `allowUnspecifiedFields: true` on the `documents` and `insertDocument` mapTarget declarations inside `insertDocument`.
- ALWAYS place `deleteDocuments` inside a `MAP { TRANSFORM ... }` wrapper — never as a top-level `INVOKE`.
- ALWAYS add `drop \`documents\`;` after each `deleteDocuments` TRANSFORM (and after each `insertDocument` INVOKE) to prevent the native `documents` output from bleeding into subsequent steps.

## EXAMPLE 42: PIPE-DELIMITED CSV PARSING WITH EXECUTION METADATA
**User:** 'Create a service processBankTransferCsv that takes a pipe-delimited CSV string csvData as input and returns jsonOutput as a String. Parse the CSV line by line, skipping the header row, split each data row by comma into fields, build a transferRow record per row and accumulate them into a list. Wrap the list with executionStarted and executionCompleted ISO-8601 timestamps and serialise to JSON.'

**Note:** Uses `pub.string:tokenize` (not FlatFile) twice — once to split rows by `|`, once to split each row by `,`. Header skip uses an `IF (%$iterationCount% != "0")` guard (not `CONTINUE` — CONTINUE inside LOOP is not permitted). Dynamic array indexing uses `set (variable) field = "%list[$iterationCount]%"` — NOT `copy list[$iterationCount] -> field` (illegal group reference). Accumulator uses `pub.list:appendToDocumentList` with `toList` fed back into itself (BP-008: never drop `toList` inside the loop). Final serialisation uses `pub.json:documentToJSONString` with backtick-escaped `\`document\`` (reserved keyword, BP-009). Timestamps captured via `pub.datetime:build` with backtick-escaped `\`pattern\`` and output `\`value\``.

    interface bankTransfers
    
    service processBankTransferCsv (
        input {
            String csvData;
        }
        output {
            String jsonOutput;
        }
    )
    properties {
        comment: "Parses a pipe-delimited CSV string of bank transfer records, converts them to a JSON structure, and appends execution metadata (start timestamp and completion timestamp).";
    }
    {
        INVOKE pub.datetime:build {
            input {
                mapTarget {
                    String `pattern`;
                }
                set `pattern` = "yyyy-MM-dd'T'HH:mm:ss.SSS";
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String startedAt;
                }
                copy `value` -> startedAt;
            }
        }
        INVOKE pub.string:tokenize {
            input {
                mapSource {
                    String csvData;
                }
                mapTarget {
                    String inString;
                    String delim;
                }
                copy csvData -> inString;
                set delim = "|";
            }
            output {
                mapSource {
                    String[] valueList;
                }
                mapTarget {
                    String[] rowList;
                }
                copy valueList -> rowList;
            }
        }
        LOOP {
            inputArray: "/rowList"
            MAP {
                mapSource {
                    String[] rowList;
                }
                mapTarget {
                    String currentRow;
                }
                set (variable) currentRow = "%rowList[$iterationCount]%";
            }
            INVOKE pub.string:trim {
                input {
                    mapSource {
                        String currentRow;
                    }
                    mapTarget {
                        String inString;
                    }
                    copy currentRow -> inString;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String trimmedRow;
                    }
                    copy `value` -> trimmedRow;
                }
            }
            IF (%$iterationCount% != "0") {
                INVOKE pub.string:tokenize {
                    input {
                        mapSource {
                            String trimmedRow;
                        }
                        mapTarget {
                            String inString;
                            String delim;
                        }
                        copy trimmedRow -> inString;
                        set delim = ",";
                    }
                    output {
                        mapSource {
                            String[] valueList;
                        }
                        mapTarget {
                            String[] fieldList;
                        }
                        copy valueList -> fieldList;
                    }
                }
                MAP {
                    mapSource {
                        String[] fieldList;
                    }
                    mapTarget {
                        String transferDate;
                        String fromAccount;
                        String toAccount;
                        String amount;
                        String currency;
                        String reference;
                    }
                    set (variable) transferDate = "%fieldList[0]%";
                    set (variable) fromAccount = "%fieldList[1]%";
                    set (variable) toAccount = "%fieldList[2]%";
                    set (variable) amount = "%fieldList[3]%";
                    set (variable) currency = "%fieldList[4]%";
                    set (variable) reference = "%fieldList[5]%";
                }
                MAP {
                    mapSource {
                        String transferDate;
                        String fromAccount;
                        String toAccount;
                        String amount;
                        String currency;
                        String reference;
                    }
                    mapTarget {
                        record transferRow {
                            String transferDate;
                            String fromAccount;
                            String toAccount;
                            String amount;
                            String currency;
                            String reference;
                        };
                    }
                    copy transferDate -> transferRow/transferDate;
                    copy fromAccount -> transferRow/fromAccount;
                    copy toAccount -> transferRow/toAccount;
                    copy amount -> transferRow/amount;
                    copy currency -> transferRow/currency;
                    copy reference -> transferRow/reference;
                }
                INVOKE pub.list:appendToDocumentList {
                    input {
                        mapSource {
                            record transferRow {
                            };
                            recordList toList;
                        }
                        mapTarget {
                            record fromItem {
                            };
                            recordList toList;
                        }
                        copy transferRow -> fromItem;
                        copy toList -> toList;
                    }
                    output {
                        mapSource {
                            recordList toList;
                        }
                        mapTarget {
                            recordList toList;
                        }
                        copy toList -> toList;
                    }
                }
            }
        }
        INVOKE pub.datetime:build {
            input {
                mapTarget {
                    String `pattern`;
                }
                set `pattern` = "yyyy-MM-dd'T'HH:mm:ss.SSS";
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String completedAt;
                }
                copy `value` -> completedAt;
            }
        }
        MAP {
            mapSource {
                recordList toList;
                String startedAt;
                String completedAt;
            }
            mapTarget {
                record result {
                    recordList transfers;
                    String executionStarted;
                    String executionCompleted;
                };
            }
            copy toList -> result/transfers;
            copy startedAt -> result/executionStarted;
            copy completedAt -> result/executionCompleted;
        }
        INVOKE pub.json:documentToJSONString {
            input {
                mapSource {
                    record result {
                    };
                }
                mapTarget {
                    record `document` {
                    };
                }
                copy result -> `document`;
            }
            output {
                mapSource {
                    String jsonString;
                }
                mapTarget {
                    String jsonOutput;
                }
                copy jsonString -> jsonOutput;
            }
        }
    }

## EXAMPLE 43: REST API INTEGRATION — GET AND CREATE (HTTP CLIENT PATTERN)
**User:** 'I have an API for my self developed legacy classic-models backend system/database, but we're going to move to a modern SaaS platform. Can you create me some webMethods flow services so I can switch my ecommerce site to use these, and then I can pivot the integration to salesforce when we cut over. I want you to create the following flow services: 1) Get Customer 2) create a customer. The API specification is here: http://mycompany.com/demo/classicmodels/openapi/openapi.yaml'

**Note:** Two separate services are generated — one per API operation. Both use `pub.client:http` wrapped in a TRY/CATCH. The response body is a byte stream: always pipe `body/bytes` through `pub.string:bytesToString` then `pub.json:jsonStringToDocument` before mapping fields. Headers (including `X-API-Key`) must be materialised as a `record headers { ... }` document — initialise the record structure in one MAP then populate values in a second MAP before the HTTP call. For POST, the request body is assembled as a record, serialised with `pub.json:documentToJSONString`, then passed as `data/string` to `pub.client:http`. The `apiKey` is taken as a runtime input parameter so the caller (ecommerce site) supplies it from config — this makes the service interface stable when pivoting the backend from ClassicModels to Salesforce. Dynamic path parameters are concatenated into the URL string using `pub.string:concat`. On any HTTP or parse failure, EXIT with `signal: "FAILURE"` inside the CATCH block.

### getCustomer (GET /customers/{customerNumber})

    interface classicModels
    
    service getCustomer (
        input {
            String customerNumber;
            String apiKey;
        }
        output {
            String customerName;
            String contactLastName;
            String contactFirstName;
            String phone;
            String addressLine1;
            String addressLine2;
            String city;
            String state;
            String postalCode;
            String country;
            String salesRepEmployeeNumber;
            String creditLimit;
        }
    )
    properties {
        comment: "Retrieves a single customer from the ClassicModels REST API by customer number. Calls GET /customers/{customerNumber} using the provided API key.";
    }
    {
        INVOKE pub.string:concat {
            input {
                mapTarget {
                    String inString1;
                    String inString2;
                }
                set inString1 = "http://mycompany.com/demo/classicmodels/api/customers/";
                copy customerNumber -> inString2;
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String fullUrl;
                }
                copy `value` -> fullUrl;
            }
        }
        MAP {
            comment: "Initialise headers document with empty X-API-Key"
            mapTarget {
                record headers {
                    String X-API-Key;
                };
            }
            set `headers` = {`X-API-Key`:""};
        }
        MAP {
            comment: "Set API key header value"
            mapSource {
                String apiKey;
            }
            mapTarget {
                record headers {
                    String X-API-Key;
                };
            }
            copy apiKey -> headers/X-API-Key;
        }
        TRY {
            INVOKE pub.client:http {
                input {
                    mapSource {
                        String fullUrl;
                        record headers {
                            String X-API-Key;
                        };
                    }
                    mapTarget {
                        String url;
                        String method;
                        record headers {
                            String X-API-Key;
                        };
                    }
                    copy fullUrl -> url;
                    set method = "get";
                    copy headers/X-API-Key -> headers/X-API-Key;
                }
            }
            INVOKE pub.string:bytesToString {
                input {
                    mapSource {
                        record body {
                            Object bytes;
                        };
                    }
                    mapTarget {
                        Object bytes;
                    }
                    copy body/bytes -> bytes;
                }
                output {
                    mapSource {
                        String string;
                    }
                    mapTarget {
                        String responseString;
                    }
                    copy string -> responseString;
                }
            }
            INVOKE pub.json:jsonStringToDocument {
                input {
                    mapSource {
                        String responseString;
                    }
                    mapTarget {
                        String jsonString;
                    }
                    copy responseString -> jsonString;
                }
                output {
                    mapSource {
                        record `document` {
                        };
                    }
                    mapTarget {
                        record responseDoc {
                        };
                    }
                    copy `document` -> responseDoc;
                }
            }
        }
        CATCH {
            EXIT {
                exitFrom: "$flow"
                signal: "FAILURE"
                failureMessage: "Failed to retrieve customer from ClassicModels API"
            }
        }
        MAP {
            comment: "Extract customer fields from parsed JSON response"
            mapTarget {
                String customerName;
                String contactLastName;
                String contactFirstName;
                String phone;
                String addressLine1;
                String addressLine2;
                String city;
                String state;
                String postalCode;
                String country;
                String salesRepEmployeeNumber;
                String creditLimit;
            }
            set (variable) customerName = "%responseDoc/customerName%";
            set (variable) contactLastName = "%responseDoc/contactLastName%";
            set (variable) contactFirstName = "%responseDoc/contactFirstName%";
            set (variable) phone = "%responseDoc/phone%";
            set (variable) addressLine1 = "%responseDoc/addressLine1%";
            set (variable) addressLine2 = "%responseDoc/addressLine2%";
            set (variable) city = "%responseDoc/city%";
            set (variable) state = "%responseDoc/state%";
            set (variable) postalCode = "%responseDoc/postalCode%";
            set (variable) country = "%responseDoc/country%";
            set (variable) salesRepEmployeeNumber = "%responseDoc/salesRepEmployeeNumber%";
            set (variable) creditLimit = "%responseDoc/creditLimit%";
        }
    }

### createCustomer (POST /customers)

    interface classicModels
    
    service createCustomer (
        input {
            String apiKey;
            String customerName;
            String contactLastName;
            String contactFirstName;
            String phone;
            String addressLine1;
            String addressLine2;
            String city;
            String state;
            String postalCode;
            String country;
            String salesRepEmployeeNumber;
            String creditLimit;
        }
        output {
            String customerNumber;
            String customerName;
            String contactLastName;
            String contactFirstName;
            String phone;
            String addressLine1;
            String city;
            String country;
        }
    )
    properties {
        comment: "Creates a new customer via the ClassicModels REST API. Calls POST /customers with a JSON body and the provided API key. Returns the created customer record including the assigned customer number.";
    }
    {
        MAP {
            comment: "Build request body document from input fields"
            mapSource {
                String customerName;
                String contactLastName;
                String contactFirstName;
                String phone;
                String addressLine1;
                String addressLine2;
                String city;
                String state;
                String postalCode;
                String country;
                String salesRepEmployeeNumber;
                String creditLimit;
            }
            mapTarget {
                record requestBody {
                    String customerName;
                    String contactLastName;
                    String contactFirstName;
                    String phone;
                    String addressLine1;
                    String addressLine2;
                    String city;
                    String state;
                    String postalCode;
                    String country;
                    String salesRepEmployeeNumber;
                    String creditLimit;
                };
            }
            copy customerName -> requestBody/customerName;
            copy contactLastName -> requestBody/contactLastName;
            copy contactFirstName -> requestBody/contactFirstName;
            copy phone -> requestBody/phone;
            copy addressLine1 -> requestBody/addressLine1;
            copy addressLine2 -> requestBody/addressLine2;
            copy city -> requestBody/city;
            copy state -> requestBody/state;
            copy postalCode -> requestBody/postalCode;
            copy country -> requestBody/country;
            copy salesRepEmployeeNumber -> requestBody/salesRepEmployeeNumber;
            copy creditLimit -> requestBody/creditLimit;
        }
        INVOKE pub.json:documentToJSONString {
            input {
                mapSource {
                    record requestBody {
                    };
                }
                mapTarget {
                    record `document` {
                    };
                }
                copy requestBody -> `document`;
            }
            output {
                mapSource {
                    String jsonString;
                }
                mapTarget {
                    String requestJson;
                }
                copy jsonString -> requestJson;
            }
        }
        MAP {
            comment: "Initialise headers document with empty X-API-Key and Content-Type"
            mapTarget {
                record headers {
                    String X-API-Key;
                    String Content-Type;
                };
            }
            set `headers` = {`X-API-Key`:"",`Content-Type`:""};
        }
        MAP {
            comment: "Populate header values from pipeline"
            mapSource {
                String apiKey;
                String requestJson;
            }
            mapTarget {
                record headers {
                    String X-API-Key;
                    String Content-Type;
                };
            }
            copy apiKey -> headers/X-API-Key;
            set headers/Content-Type = "application/json";
        }
        TRY {
            INVOKE pub.client:http {
                input {
                    mapSource {
                        String requestJson;
                        record headers {
                            String X-API-Key;
                            String Content-Type;
                        };
                    }
                    mapTarget {
                        String url;
                        String method;
                        record data {
                            String string;
                        };
                        record headers {
                            String X-API-Key;
                            String Content-Type;
                        };
                    }
                    set url = "http://mycompany.com/demo/classicmodels/api/customers";
                    set method = "post";
                    copy requestJson -> data/string;
                    copy headers/X-API-Key -> headers/X-API-Key;
                    copy headers/Content-Type -> headers/Content-Type;
                }
            }
            INVOKE pub.string:bytesToString {
                input {
                    mapSource {
                        record body {
                            Object bytes;
                        };
                    }
                    mapTarget {
                        Object bytes;
                    }
                    copy body/bytes -> bytes;
                }
                output {
                    mapSource {
                        String string;
                    }
                    mapTarget {
                        String responseString;
                    }
                    copy string -> responseString;
                }
            }
            INVOKE pub.json:jsonStringToDocument {
                input {
                    mapSource {
                        String responseString;
                    }
                    mapTarget {
                        String jsonString;
                    }
                    copy responseString -> jsonString;
                }
                output {
                    mapSource {
                        record `document` {
                        };
                    }
                    mapTarget {
                        record responseDoc {
                        };
                    }
                    copy `document` -> responseDoc;
                }
            }
        }
        CATCH {
            EXIT {
                exitFrom: "$flow"
                signal: "FAILURE"
                failureMessage: "Failed to create customer via ClassicModels API"
            }
        }
        MAP {
            comment: "Extract created customer fields from parsed JSON response"
            mapTarget {
                String customerNumber;
                String customerName;
                String contactLastName;
                String contactFirstName;
                String phone;
                String addressLine1;
                String city;
                String country;
            }
            set (variable) customerNumber = "%responseDoc/customerNumber%";
            set (variable) customerName = "%responseDoc/customerName%";
            set (variable) contactLastName = "%responseDoc/contactLastName%";
            set (variable) contactFirstName = "%responseDoc/contactFirstName%";
            set (variable) phone = "%responseDoc/phone%";
            set (variable) addressLine1 = "%responseDoc/addressLine1%";
            set (variable) city = "%responseDoc/city%";
            set (variable) country = "%responseDoc/country%";
        }
    }

## EXAMPLE 44: SIMPLE ARITHMETIC — ADD TWO NUMBERS
**User:** 'Create me a flow service that adds two numbers together and returns the sum as an output.'

**Note:** Uses `pub.math:addInts` — catalog inputs are `num1` and `num2` (both String); catalog output is `value` (String). `value` is a reserved keyword and MUST be backtick-wrapped in the `mapSource` block. `num1`, `num2`, and `sum` are plain identifiers — no backticks. No `drop` statements are emitted unless the user explicitly names variables to drop (zero-drop default, BP-035). The service signature uses `properties { comment: "..."; }` placed between the closing `)` of the signature and the opening `{` of the body.

    interface mathServices
    
    service addNumbers (
        input {
            String num1;
            String num2;
        }
        output {
            String sum;
        }
    )
    properties {
        comment: "Adds two integer values (passed as Strings) and returns the sum.";
    }
    {
        INVOKE pub.math:addInts {
            input {
                mapSource {
                    String num1;
                    String num2;
                }
                mapTarget {
                    String num1;
                    String num2;
                }
                copy num1 -> num1;
                copy num2 -> num2;
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String sum;
                }
                copy `value` -> sum;
            }
        }
    }

## EXAMPLE 45: EXTERNAL REST API CALL WITH DYNAMIC URL, TRY/CATCH, AND PIPELINE DROPS
**User:** 'I want a flow service that returns me a Chuck Norris joke. I'd like to provide a category as an input, and you return a joke from that category as an output. The API is here: https://api.chucknorris.io/'

**Note:** This example demonstrates the full HTTP client pattern with explicit pipeline drops at every step. Key rules: (1) Build the URL dynamically with `pub.string:concat` — drop `value` (reserved keyword, backtick-wrapped) in the INVOKE output block immediately after use. (2) `pub.client:http` has **NO `output {}` block** — the catalog output `body/bytes` is referenced directly in the next step's `mapSource`. (3) **BP-004**: `body/bytes` must be declared as `Object bytes` (not `Byte[]`) in both the `pub.string:bytesToString` input `mapSource` and `mapTarget` — the catalog says `byte[]` but the actual runtime type is `Object`. (4) `pub.json:jsonStringToDocument` output parameter is named `document` — backtick-wrap it everywhere as `` `document` `` (reserved keyword, BP-009). (5) **BP-006**: the output-promotion MAP goes **after** the CATCH, never inside the TRY. (6) **BP-010**: extract the single `value` field from the parsed document using `set (variable) joke = "%jokeDoc/value%"` — no backticks needed inside `%...%` paths. (7) `drop` is applied immediately after each variable is consumed — `fullUrl` dropped inside the `pub.client:http` input block, `body` dropped inside `bytesToString` input, `string` dropped in `bytesToString` output, `responseString` dropped in `jsonStringToDocument` input, `` `document` `` dropped in `jsonStringToDocument` output, and `jokeDoc` dropped in the trailing MAP. This keeps the pipeline clean at every step. The chucknorris.io API requires no authentication — no headers needed. Run with `category = "dev"` to get a developer joke.

    interface chuckNorris
    
    service getChuckNorrisJoke (
        input {
            String category;
        }
        output {
            String joke;
        }
    )
    properties {
        comment: "Retrieves a random Chuck Norris joke from the chucknorris.io API for the given category.";
    }
    {
        INVOKE pub.string:concat {
            input {
                mapSource {
                    String category;
                }
                mapTarget {
                    String inString1;
                    String inString2;
                }
                set inString1 = "https://api.chucknorris.io/jokes/random?category=";
                copy category -> inString2;
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String fullUrl;
                }
                copy `value` -> fullUrl;
                drop `value`;
            }
        }
        TRY {
            INVOKE pub.client:http {
                input {
                    mapSource {
                        String fullUrl;
                    }
                    mapTarget {
                        String url;
                        String method;
                    }
                    copy fullUrl -> url;
                    set method = "get";
                    drop fullUrl;
                }
            }
            INVOKE pub.string:bytesToString {
                input {
                    mapSource {
                        record body {
                            Object bytes;
                        };
                    }
                    mapTarget {
                        Object bytes;
                    }
                    copy body/bytes -> bytes;
                    drop body;
                }
                output {
                    mapSource {
                        String string;
                    }
                    mapTarget {
                        String responseString;
                    }
                    copy string -> responseString;
                    drop string;
                }
            }
            INVOKE pub.json:jsonStringToDocument {
                input {
                    mapSource {
                        String responseString;
                    }
                    mapTarget {
                        String jsonString;
                    }
                    copy responseString -> jsonString;
                    drop responseString;
                }
                output {
                    mapSource {
                        record `document` {
                        };
                    }
                    mapTarget {
                        record jokeDoc {
                        };
                    }
                    copy `document` -> jokeDoc;
                    drop `document`;
                }
            }
        }
        CATCH {
            EXIT {
                exitFrom: "$flow"
                signal: "FAILURE"
                failureMessage: "Failed to retrieve Chuck Norris joke from chucknorris.io"
            }
        }
        MAP {
            comment: "Extract joke text from parsed JSON response"
            mapTarget {
                String joke;
            }
            set (variable) joke = "%jokeDoc/value%";
            drop jokeDoc;
        }
    }

## EXAMPLE 46: TITLE CASE CONVERSION — LOOP-BASED WORD PROCESSING WITH CLEAN PIPELINE
**User:** 'Create me a flow service that takes a string and turns it into title case. For example: "hi my name is cristiano ronaldo" would become "Hi My Name Is Cristiano Ronaldo".'

**Note:** No `pub.string:toTitleCase` service exists in the catalog — this must be composed from primitives. Algorithm: (1) `pub.string:tokenize` splits on `" "` → `wordList`; (2) `LOOP { inputArray: "/wordList" }` iterates each word; per iteration: extract current word using `set (variable) currentWord = "%wordList[$iterationCount]%"`, take first char with `pub.string:substring` (`beginIndex="0"`, `endIndex="1"`), uppercase it with `pub.string:toUpper`, take rest with a second `pub.string:substring` (`beginIndex="1"`, `endIndex=""`), lowercase with `pub.string:toLower`, join with `pub.string:concat`, accumulate with `pub.list:appendToStringList`; (3) after the loop, `pub.string:makeString` rejoins with `separator=" "`. **BP-002 critical:** the first `substring` call sets `endIndex="1"` into the pipeline — the second `substring` call MUST explicitly set `endIndex=""` to clear the stale value, otherwise every word is silently truncated to one character. **BP-008:** `toList` is NEVER dropped inside the LOOP — it must feed back into itself on every iteration. `wordList` is dropped after the LOOP in a standalone MAP (not inside the loop). All `value` outputs are reserved keywords — backtick-wrap everywhere in `mapSource`. All intermediate variables (`firstChar`, `firstCharUpper`, `restOfWord`, `restLower`, `titleWord`, `currentWord`) are dropped as soon as they are no longer needed for a clean pipeline.

    interface stringUtils
    
    service toTitleCase (
        input {
            String inputString;
        }
        output {
            String titleCaseOutput;
        }
    )
    properties {
        comment: "Converts a string to title case by capitalising the first letter of each word and lowercasing the remainder.";
    }
    {
        INVOKE pub.string:tokenize {
            input {
                mapSource {
                    String inputString;
                }
                mapTarget {
                    String inString;
                    String delim;
                }
                copy inputString -> inString;
                set delim = " ";
                drop inputString;
            }
            output {
                mapSource {
                    String[] valueList;
                }
                mapTarget {
                    String[] wordList;
                }
                copy valueList -> wordList;
                drop valueList;
            }
        }
        LOOP {
            inputArray: "/wordList"
            MAP {
                mapSource {
                    String[] wordList;
                }
                mapTarget {
                    String currentWord;
                }
                set (variable) currentWord = "%wordList[$iterationCount]%";
            }
            INVOKE pub.string:substring {
                input {
                    mapSource {
                        String currentWord;
                    }
                    mapTarget {
                        String inString;
                        String beginIndex;
                        String endIndex;
                    }
                    copy currentWord -> inString;
                    set beginIndex = "0";
                    set endIndex = "1";
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String firstChar;
                    }
                    copy `value` -> firstChar;
                    drop `value`;
                }
            }
            INVOKE pub.string:toUpper {
                input {
                    mapSource {
                        String firstChar;
                    }
                    mapTarget {
                        String inString;
                    }
                    copy firstChar -> inString;
                    drop firstChar;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String firstCharUpper;
                    }
                    copy `value` -> firstCharUpper;
                    drop `value`;
                }
            }
            INVOKE pub.string:substring {
                input {
                    mapSource {
                        String currentWord;
                    }
                    mapTarget {
                        String inString;
                        String beginIndex;
                        String endIndex;
                    }
                    copy currentWord -> inString;
                    set beginIndex = "1";
                    set endIndex = "";
                    drop currentWord;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String restOfWord;
                    }
                    copy `value` -> restOfWord;
                    drop `value`;
                }
            }
            INVOKE pub.string:toLower {
                input {
                    mapSource {
                        String restOfWord;
                    }
                    mapTarget {
                        String inString;
                    }
                    copy restOfWord -> inString;
                    drop restOfWord;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String restLower;
                    }
                    copy `value` -> restLower;
                    drop `value`;
                }
            }
            INVOKE pub.string:concat {
                input {
                    mapSource {
                        String firstCharUpper;
                        String restLower;
                    }
                    mapTarget {
                        String inString1;
                        String inString2;
                    }
                    copy firstCharUpper -> inString1;
                    copy restLower -> inString2;
                    drop firstCharUpper;
                    drop restLower;
                }
                output {
                    mapSource {
                        String `value`;
                    }
                    mapTarget {
                        String titleWord;
                    }
                    copy `value` -> titleWord;
                    drop `value`;
                }
            }
            INVOKE pub.list:appendToStringList {
                input {
                    mapSource {
                        String titleWord;
                        String[] toList;
                    }
                    mapTarget {
                        String fromItem;
                        String[] toList;
                    }
                    copy titleWord -> fromItem;
                    copy toList -> toList;
                    drop titleWord;
                }
                output {
                    mapSource {
                        String[] toList;
                    }
                    mapTarget {
                        String[] toList;
                    }
                    copy toList -> toList;
                }
            }
        }
        MAP {
            mapTarget {
                String[] wordList;
            }
            drop wordList;
        }
        INVOKE pub.string:makeString {
            input {
                mapSource {
                    String[] toList;
                }
                mapTarget {
                    String[] elementList;
                    String separator;
                }
                copy toList -> elementList;
                set separator = " ";
                drop toList;
            }
            output {
                mapSource {
                    String `value`;
                }
                mapTarget {
                    String titleCaseOutput;
                }
                copy `value` -> titleCaseOutput;
                drop `value`;
            }
        }
    }
