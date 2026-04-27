---
title: "Building with Claude: A Practical Developer Guide to Models, APIs, Prompts, Tools, RAG, MCP, and Agents"
date: 2025-12-28T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Claude", "Python", "LLMs"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Building with Claude: A Practical Developer Guide to Models, APIs, Prompts, Tools, RAG, MCP, and Agents"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link

---
# Building with Claude: A Practical Developer Guide to Models, APIs, Prompts, Tools, RAG, MCP, and Agents

Claude is not just a chatbot interface. It is a platform for building AI-powered applications: assistants, coding tools, document processors, data analysers, retrieval systems, workflow automations, and agents that can use external tools.

This guide walks through the main concepts a developer needs to understand when building with Claude: how to choose a model, how API requests work, how to manage conversations, how to control outputs, how to evaluate prompts, how tool use works, how to build RAG systems, how MCP fits into the architecture, and when to use workflows versus agents.

---

## 1. Claude Model Families

Claude models are organised into three broad families, each optimised for a different priority: intelligence, balance, or speed.

### Opus

Opus is the highest-intelligence Claude model family. It is designed for complex, multi-step work where reasoning, planning, and careful analysis matter more than cost or latency.

Typical use cases include:

* Complex architecture design
* Multi-step reasoning tasks
* Deep analysis of long documents
* Planning and strategy
* High-stakes coding or debugging
* Tasks where accuracy matters more than speed

The trade-off is that Opus is generally slower and more expensive than the other families.

### Sonnet

Sonnet is the balanced family. It offers strong reasoning, good speed, and cost efficiency. For most production applications, Sonnet is usually the best default choice.

It is especially strong for:

* Software development
* Precise code editing
* General assistants
* Business workflows
* Document processing
* Production chat applications
* Tasks that need quality without excessive latency

If you are unsure which model to choose, start with Sonnet.

### Haiku

Haiku is optimised for speed and cost efficiency. It is the best fit when you need fast responses or high-volume processing.

Typical use cases include:

* Classification
* Routing
* Lightweight extraction
* Real-time user interactions
* High-throughput batch processing
* Simple summarisation
* Dataset generation for evaluations

Haiku is not the best choice for tasks that need deep reasoning, but it is extremely useful as part of a larger system.

### Model selection framework

A simple selection framework:

| Priority              | Model family |
| --------------------- | ------------ |
| Highest intelligence  | Opus         |
| Best balance          | Sonnet       |
| Lowest latency / cost | Haiku        |

In mature applications, the best architecture is often not “pick one model”. Instead, use different models for different parts of the system. For example:

* Haiku classifies the request.
* Sonnet generates the main response.
* Opus handles complex escalations.

All Claude model families share core capabilities such as text generation, coding, and image analysis. The main difference is their optimisation profile.

---

## 2. How Claude API Access Works

A typical Claude-powered application should not call the Anthropic API directly from a browser or mobile client. The API key must remain secret, so requests should go through your backend.

The standard flow looks like this:

```text
User → Client app → Your server → Anthropic API → Your server → Client app → User
```

### Five-step request flow

1. The user enters text in the client application.
2. The client sends the text to your server.
3. Your server calls the Anthropic API using an SDK or HTTP.
4. Claude generates a response.
5. The API returns the generated text, usage information, and a stop reason. Your server sends the result back to the client.

Anthropic provides SDKs for several languages, including Python, TypeScript, JavaScript, Go, and Ruby. You can also use plain HTTP.

A request normally includes:

* API key
* Model name
* Message list
* `max_tokens` limit
* Optional parameters such as `system`, `temperature`, `tools`, `stop_sequences`, or streaming options

---

## 3. What Happens During Text Generation

Although you do not need to implement the internals of a language model, understanding the high-level process helps when debugging behaviour.

Claude’s generation process can be understood in four broad stages.

### 1. Tokenisation

The input text is broken into tokens. A token may be a word, part of a word, punctuation mark, symbol, or space.

For example, a sentence is not necessarily processed word by word. Some words may be split into multiple tokens.

### 2. Embedding

Each token is converted into a numerical representation. This representation captures possible meanings and relationships.

An embedding is essentially a list of numbers representing semantic properties of the token.

### 3. Contextualisation

The model adjusts token meanings based on neighbouring tokens.

For example, the word “bank” can mean a financial institution or the side of a river. Context determines the intended meaning.

### 4. Generation

Claude predicts possible next tokens and assigns probabilities to them. It selects a token based on those probabilities and generation settings, then repeats the process until it stops.

The model stops when:

* It reaches the `max_tokens` limit.
* It generates an end-of-sequence token.
* It reaches a stop sequence.
* It pauses to request tool use.

The response includes a `stop_reason`, which tells you why generation ended.

---

## 4. Making Your First API Request

A basic Python setup usually involves installing the Anthropic SDK and loading your API key from an environment variable.

```bash
pip install anthropic python-dotenv
```

Create a `.env` file:

```bash
ANTHROPIC_API_KEY="your_key_here"
```

Do not commit this file to version control.

Then create a client and send a request:

```python
import os
from dotenv import load_dotenv
import anthropic

load_dotenv()

client = anthropic.Anthropic(
    api_key=os.environ["ANTHROPIC_API_KEY"]
)

model = "claude-3-5-sonnet-latest"

message = client.messages.create(
    model=model,
    max_tokens=1000,
    messages=[
        {
            "role": "user",
            "content": "What is quantum computing?"
        }
    ]
)

print(message.content[0].text)
```

### Required request fields

| Field        | Purpose                  |
| ------------ | ------------------------ |
| `model`      | The Claude model to use  |
| `max_tokens` | Maximum generated tokens |
| `messages`   | Conversation messages    |

`max_tokens` is not a target response length. It is a safety limit.

### Message structure

Claude messages use roles:

```python
{"role": "user", "content": "Human-authored text"}
```

Assistant messages represent model-generated responses:

```python
{"role": "assistant", "content": "Model-generated text"}
```

The API response contains metadata and nested content blocks. To access just the text:

```python
text = message.content[0].text
```

---

## 5. Multi-Turn Conversations

The Anthropic API is stateless. It does not remember previous requests.

That means this will not work as expected:

```text
Request 1: My name is Ana.
Request 2: What is my name?
```

Unless you include the first message again in the second request, Claude has no memory of it.

### The solution: maintain message history yourself

You need to:

1. Store the message list in your application.
2. Append each user message.
3. Append each assistant response.
4. Send the full history with every new request.

Example:

```python
messages = []

def add_user_message(messages, text):
    messages.append({
        "role": "user",
        "content": text
    })


def add_assistant_message(messages, text):
    messages.append({
        "role": "assistant",
        "content": text
    })


def chat(messages):
    response = client.messages.create(
        model=model,
        max_tokens=1000,
        messages=messages
    )
    return response.content[0].text


while True:
    user_input = input("> ")
    add_user_message(messages, user_input)

    answer = chat(messages)
    add_assistant_message(messages, answer)

    print("---")
    print(answer)
    print("---")
```

This is the foundation for any chat application.

---

## 6. System Prompts

A system prompt lets you define Claude’s role, style, constraints, and behaviour.

It controls how Claude responds rather than simply what it responds with.

Example:

```python
response = client.messages.create(
    model=model,
    max_tokens=1000,
    system="You are a patient math tutor. Give hints instead of direct answers. Encourage the student to reason step by step.",
    messages=[
        {
            "role": "user",
            "content": "How do I solve 2x + 5 = 15?"
        }
    ]
)
```

The same user question can produce very different answers depending on the system prompt.

### Conditional system prompts

In production code, it is common to build request parameters dynamically:

```python
def chat(messages, system_prompt=None):
    params = {
        "model": model,
        "max_tokens": 1000,
        "messages": messages,
    }

    if system_prompt is not None:
        params["system"] = system_prompt

    response = client.messages.create(**params)
    return response.content[0].text
```

This avoids sending a `None` value where the API expects a string.

---

## 7. Temperature

Temperature controls randomness during token selection.

At each generation step, Claude has a probability distribution over possible next tokens. Temperature changes how dominant the most likely tokens are.

### Low temperature

Low temperature makes outputs more consistent and deterministic.

Use it for:

* Data extraction
* Factual responses
* Classification
* JSON generation
* Code transformations
* Tasks where consistency matters

Example:

```python
response = client.messages.create(
    model=model,
    max_tokens=1000,
    temperature=0,
    messages=[
        {
            "role": "user",
            "content": "Extract the email addresses from this text."
        }
    ]
)
```

### High temperature

Higher temperature increases the chance of less obvious tokens being selected.

Use it for:

* Brainstorming
* Creative writing
* Jokes
* Marketing copy
* Ideation

Higher temperature does not guarantee different outputs every time. It only increases the likelihood of variation.

---

## 8. Streaming Responses

Without streaming, users may wait 10–30 seconds for long responses. A spinner is a poor experience compared with showing tokens as they arrive.

Streaming sends response chunks incrementally.

### Basic streaming concept

1. Your server sends a request to Claude.
2. Claude acknowledges the message.
3. Claude streams events as generation progresses.
4. Your server forwards text chunks to the frontend.
5. The final message is assembled for storage.

Common event types include:

| Event                 | Meaning                |
| --------------------- | ---------------------- |
| `message_start`       | Response begins        |
| `content_block_start` | A content block begins |
| `content_block_delta` | New text chunk arrives |
| `content_block_stop`  | Content block ends     |
| `message_stop`        | Full response ends     |

### Simplified streaming with `text_stream`

```python
with client.messages.stream(
    model=model,
    max_tokens=1000,
    messages=[
        {
            "role": "user",
            "content": "Write a short guide to solar panels."
        }
    ]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)

    final_message = stream.get_final_message()
```

`stream.get_final_message()` gives you the assembled response, which is useful for database storage.

---

## 9. Controlling Model Output

Prompt wording is not the only way to control output. Two useful techniques are assistant prefill and stop sequences.

### Assistant message prefill

You can manually add an assistant message at the end of the conversation. Claude treats it as already-written assistant content and continues from that exact point.

Example:

```python
messages = [
    {
        "role": "user",
        "content": "Which is better, coffee or tea?"
    },
    {
        "role": "assistant",
        "content": "Coffee is better because"
    }
]

response = client.messages.create(
    model=model,
    max_tokens=500,
    messages=messages
)
```

Claude continues after “Coffee is better because”.

Important detail: Claude continues from the exact end of the prefilled text. It does not restart the sentence or add missing context for you.

### Stop sequences

Stop sequences force generation to halt when a specific string appears.

```python
response = client.messages.create(
    model=model,
    max_tokens=1000,
    stop_sequences=[", five"],
    messages=[
        {
            "role": "user",
            "content": "Count from one to ten."
        }
    ]
)
```

If Claude generates `, five`, generation stops before that sequence appears in the final output.

This is useful when you need precise control over length or delimiters.

---

## 10. Structured Data Generation

Claude often adds helpful explanations, Markdown headings, or code fences. That is useful for humans, but annoying when you need raw JSON, Python, YAML, regex, or another parseable format.

A common pattern combines:

1. A user request for structured data.
2. Assistant prefill with an opening delimiter.
3. A stop sequence with the closing delimiter.

Example:

````python
messages = [
    {
        "role": "user",
        "content": "Generate a JSON array of five AWS automation tasks. Each item should have a task and format field."
    },
    {
        "role": "assistant",
        "content": "```json"
    }
]

response = client.messages.create(
    model=model,
    max_tokens=1000,
    messages=messages,
    stop_sequences=["```"]
)

raw_json = response.content[0].text
````

The result is easier to parse because Claude continues inside the JSON block and stops when it reaches the closing fence.

This technique works for:

* JSON
* Python code
* YAML
* Regex
* Lists
* Configuration files
* Any structured format where extra text is undesirable

For more reliability, especially with complex structures, use tool calling with a JSON schema.

---

## 11. Prompt Evaluation

Many teams make the same mistake: they write a prompt, test it once or twice, tweak it manually, and ship it.

That is not enough for production.

Prompt evaluation gives you an objective way to improve prompts.

### Typical evaluation workflow

1. Write an initial prompt.
2. Create an evaluation dataset.
3. Interpolate each test case into the prompt.
4. Run the prompts through Claude.
5. Grade the responses.
6. Modify the prompt and repeat.

The dataset can be tiny at first. Even three to ten examples are better than relying on intuition.

### Dataset generation

You can create datasets manually, or use a fast model such as Haiku to generate test cases.

Example dataset structure:

```json
[
  {
    "task": "Create a Python script that lists all S3 buckets.",
    "format": "python"
  },
  {
    "task": "Create a JSON config for an AWS Lambda timeout setting.",
    "format": "json"
  },
  {
    "task": "Write a regex that matches IPv4 addresses.",
    "format": "regex"
  }
]
```

You can use structured generation techniques to produce this dataset, parse it, and save it as `dataset.json`.

### Running the evaluation

A basic evaluation system often has three core functions:

```python
def run_prompt(test_case, prompt_template):
    prompt = prompt_template.format(**test_case)
    response = client.messages.create(
        model=model,
        max_tokens=1000,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.content[0].text


def run_test_case(test_case, prompt_template, grader):
    output = run_prompt(test_case, prompt_template)
    score = grader(output, test_case)
    return {
        "test_case": test_case,
        "output": output,
        "score": score,
    }


def run_eval(dataset, prompt_template, grader):
    return [
        run_test_case(test_case, prompt_template, grader)
        for test_case in dataset
    ]
```

This gives you comparable results across prompt versions.

---

## 12. Grading Model Outputs

There are three common ways to grade LLM outputs.

### 1. Code-based graders

These are deterministic checks written in code. They are ideal for structured outputs.

Examples:

```python
import json
import ast
import re


def validate_json(text):
    try:
        json.loads(text)
        return 10
    except Exception:
        return 0


def validate_python(text):
    try:
        ast.parse(text)
        return 10
    except Exception:
        return 0


def validate_regex(text):
    try:
        re.compile(text)
        return 10
    except Exception:
        return 0
```

These validators do not prove the output is semantically correct, but they catch invalid syntax.

### 2. Model-based graders

A model-based grader asks another model to evaluate the output.

A good grading prompt should ask for:

* Strengths
* Weaknesses
* Reasoning
* Numerical score

Do not ask only for a score. Models often default to middling scores unless forced to reason.

Example expected grader output:

```json
{
  "strengths": ["Valid JSON", "Correct field names"],
  "weaknesses": ["Missing one requested field"],
  "reasoning": "The answer mostly follows the requested structure but omits the region field.",
  "score": 7
}
```

### 3. Human graders

Human review is the most flexible and often the most accurate, but it is slower and expensive. It is useful for calibrating model-based graders or reviewing high-impact outputs.

### Combining graders

For technical tasks, combine semantic grading and syntax validation:

```text
final_score = (model_score + syntax_score) / 2
```

This captures both correctness and technical validity.

---

## 13. Prompt Engineering Techniques That Actually Help

Prompt engineering is not magic phrasing. It is the process of making instructions clear, specific, structured, and testable.

### Be clear and direct

The first line matters. Start with an action verb and state the task plainly.

Poor:

```text
I need some help with food for someone who trains.
```

Better:

```text
Generate a one-day meal plan for an athlete based on the provided height, weight, goal, and dietary restrictions.
```

Good first lines often follow this pattern:

```text
[Action verb] + [specific task] + [output expectation]
```

Examples:

```text
Write three paragraphs explaining how solar panels work.
```

```text
Identify three countries that use geothermal energy and include generation statistics for each.
```

```text
Generate a one-day meal plan for an athlete that respects their dietary restrictions.
```

### Be specific

Specificity usually improves results dramatically.

There are two useful types of guidelines.

#### Type A: output attributes

These define what the answer should look like.

Examples:

* Length
* Structure
* Format
* Tone
* Required sections
* Required fields
* Forbidden content

#### Type B: reasoning or process steps

These tell the model how to approach the problem.

Examples:

```text
First identify the user’s goal, then list constraints, then generate the plan, then verify that each constraint is satisfied.
```

Use Type A guidelines almost always. Use Type B guidelines when the task is complex or requires considering multiple perspectives.

### Use XML tags for structure

When prompts contain multiple content blocks, XML-style tags make boundaries clear.

Example:

```xml
<athlete_information>
Height: 180 cm
Weight: 78 kg
Goal: gain muscle
Dietary restrictions: lactose-free
</athlete_information>

<output_requirements>
- Include breakfast, lunch, dinner, and two snacks
- Provide calories and protein estimates
- Explain why each meal supports the goal
- Return a Markdown table
</output_requirements>
```

Use descriptive tag names. `<sales_records>` is better than `<data>`.

This is especially useful for:

* Code debugging
* Document analysis
* Data extraction
* Multi-document prompts
* Long user-provided context

### Provide examples

One-shot and multi-shot prompting means giving Claude examples of the desired input/output pattern.

Examples are especially useful for:

* Complex formatting
* Corner cases
* Tone matching
* Sarcasm detection
* Data extraction
* Classification

A strong example includes both the sample output and a short explanation of why it is good.

---

## 14. Tool Use: Extending Claude Beyond Text

By default, Claude only knows what is in the prompt and its training. It cannot automatically know current weather, query your database, create reminders, or call your APIs.

Tool use solves that.

A tool is a function that your application exposes to Claude. Claude decides when it needs the tool, asks to call it, and your server executes it.

### Tool use flow

```text
User asks question
→ Claude decides a tool is needed
→ Claude returns a tool_use block
→ Your server runs the function
→ Your server sends a tool_result block back
→ Claude produces the final answer
```

Example: current weather.

```text
User: What is the weather in Lisbon?
Claude: I need weather data for Lisbon.
Server: Calls weather API.
Claude: Uses the returned weather data to answer.
```

---

## 15. Designing Tool Functions

Tool functions are plain functions executed by your code.

Good tool functions should:

* Have descriptive names
* Have descriptive argument names
* Validate inputs
* Raise meaningful errors
* Return structured results when possible

Example:

```python
from datetime import datetime


def get_current_datetime(date_format="%Y-%m-%d %H:%M:%S"):
    if not date_format:
        raise ValueError("date_format cannot be empty")

    return datetime.now().strftime(date_format)
```

Errors matter. If a tool raises a useful error, Claude can often correct the arguments and retry.

Bad error:

```text
Error
```

Good error:

```text
date_format cannot be empty. Provide a valid strftime-compatible format.
```

---

## 16. Tool Schemas

Claude needs a schema describing each tool.

A tool schema typically includes:

* `name`
* `description`
* `input_schema`

The description should explain:

* What the tool does
* When to use it
* What it returns
* Any constraints or caveats

Example schema:

```python
get_current_datetime_schema = {
    "name": "get_current_datetime",
    "description": "Gets the current date and time. Use this when the user asks about the current time, current date, or relative scheduling. Returns a formatted datetime string.",
    "input_schema": {
        "type": "object",
        "properties": {
            "date_format": {
                "type": "string",
                "description": "A Python strftime-compatible date format."
            }
        },
        "required": []
    }
}
```

In Python, you may wrap tool definitions using SDK types such as `ToolParam`, depending on the SDK version.

---

## 17. Handling Message Blocks with Tools

Once tools are introduced, messages are no longer always plain text.

An assistant response may contain multiple content blocks:

* Text block
* Tool use block
* More text blocks
* More tool use blocks

This means your message history functions must store complete content blocks, not only `message.content[0].text`.

### Tool-enabled request

```python
response = client.messages.create(
    model=model,
    max_tokens=1000,
    messages=messages,
    tools=[get_current_datetime_schema]
)
```

If Claude wants to use a tool, the response may contain a block like:

```json
{
  "type": "tool_use",
  "id": "toolu_123",
  "name": "get_current_datetime",
  "input": {
    "date_format": "%Y-%m-%d"
  }
}
```

You must append the full assistant response to the message history.

---

## 18. Sending Tool Results Back to Claude

After executing a tool, your application must send a tool result block back to Claude.

A tool result includes:

* `tool_use_id`
* `content`
* `is_error`

Example:

```python
tool_result = {
    "type": "tool_result",
    "tool_use_id": "toolu_123",
    "content": "2026-04-27 14:30:00",
    "is_error": False
}

messages.append({
    "role": "user",
    "content": [tool_result]
})
```

The `tool_use_id` links the result to the original tool request. This is essential when Claude requests multiple tools.

Important: tool results are sent as a user message, not an assistant message.

---

## 19. Multi-Turn Tool Conversations

Some tasks require multiple tool calls.

Example:

```text
User: What day is 103 days from today?
```

Claude may need to:

1. Call `get_current_datetime`.
2. Call `add_duration_to_datetime`.
3. Return the final answer.

You cannot always predict how many tool calls will be required. The solution is a loop.

### Conversation loop

```python
def run_conversation(messages, tools):
    while True:
        response = client.messages.create(
            model=model,
            max_tokens=1000,
            messages=messages,
            tools=tools
        )

        messages.append({
            "role": "assistant",
            "content": response.content
        })

        if response.stop_reason != "tool_use":
            return response

        tool_results = run_tools(response.content)

        messages.append({
            "role": "user",
            "content": tool_results
        })
```

### Running tools

```python
def run_tools(content_blocks):
    tool_results = []

    for block in content_blocks:
        if block.type != "tool_use":
            continue

        try:
            output = run_tool(block.name, block.input)
            tool_results.append({
                "type": "tool_result",
                "tool_use_id": block.id,
                "content": json.dumps(output),
                "is_error": False
            })
        except Exception as e:
            tool_results.append({
                "type": "tool_result",
                "tool_use_id": block.id,
                "content": str(e),
                "is_error": True
            })

    return tool_results
```

### Dispatching tools

```python
def run_tool(tool_name, tool_input):
    if tool_name == "get_current_datetime":
        return get_current_datetime(**tool_input)

    if tool_name == "add_duration_to_datetime":
        return add_duration_to_datetime(**tool_input)

    if tool_name == "set_reminder":
        return set_reminder(**tool_input)

    raise ValueError(f"Unknown tool: {tool_name}")
```

This architecture supports arbitrary tool chains.

---

## 20. Adding Multiple Tools

Once the framework is in place, adding a tool usually requires three steps:

1. Implement the function.
2. Add its schema to the tools list.
3. Add a case in the dispatcher.

For example, a reminder system might include:

* `get_current_datetime`
* `add_duration_to_datetime`
* `set_reminder`

Claude can then combine those tools dynamically.

This is where tools become powerful: the model can solve tasks by composing small capabilities.

---

## 21. Batch Tool Pattern

Claude can technically request multiple tools in one assistant message, but models may still call tools sequentially when they could be parallelised.

A batch tool is a workaround.

Instead of exposing only individual tools, expose a higher-level tool that accepts a list of invocations.

Example input:

```json
{
  "invocations": [
    {
      "tool_name": "get_weather",
      "arguments": {"city": "Lisbon"}
    },
    {
      "tool_name": "get_weather",
      "arguments": {"city": "Madrid"}
    }
  ]
}
```

The server runs each invocation and returns a list of outputs.

This reduces unnecessary request-response cycles when tool calls are independent.

---

## 22. Tools for Structured Data

Tool use can also be used for structured extraction.

Instead of asking Claude to output JSON as text, define a tool whose input schema is the structure you want.

Then force Claude to call that tool.

```python
response = client.messages.create(
    model=model,
    max_tokens=1000,
    messages=[
        {
            "role": "user",
            "content": "Extract the customer name, company, and requested product from this email."
        }
    ],
    tools=[extract_customer_request_schema],
    tool_choice={
        "type": "tool",
        "name": "extract_customer_request"
    }
)
```

Then read the structured arguments from the tool use block.

This approach is more complex than prefill and stop sequences, but more reliable for production extraction.

---

## 23. Fine-Grained Tool Calling and Tool Streaming

When streaming tool calls, you may receive partial JSON chunks as Claude builds tool arguments.

Standard streaming includes text deltas. Tool streaming adds JSON-related deltas such as partial argument chunks.

### Default behaviour

By default, the API may buffer chunks until it has a complete top-level key-value pair and can validate the JSON against the schema.

This gives you more safety, but can feel less like normal streaming because chunks arrive in bursts.

### Fine-grained mode

Fine-grained tool calling disables some API-side validation and streams chunks as they are generated.

Trade-off:

| Mode         | Benefit          | Risk                            |
| ------------ | ---------------- | ------------------------------- |
| Default      | Validated JSON   | Slower chunk delivery           |
| Fine-grained | Faster streaming | Client must handle invalid JSON |

Use fine-grained mode when you need immediate UI updates or want to begin processing tool arguments before the full object is complete.

---

## 24. Built-In Tools: Text Editing, Web Search, Code Execution

Claude can work with several tool patterns, including built-in tool schemas that still require application-side integration.

### Text editor tool

The text editor tool enables file operations such as:

* View files
* Create files
* Replace strings
* Edit text
* Undo operations

Claude has a built-in schema for this tool, but your application must implement the actual filesystem operations.

The typical flow is:

1. Send a minimal tool schema stub.
2. Claude expands it internally.
3. Claude requests file operations.
4. Your code performs the operations.
5. Results are sent back to Claude.

This is the foundation of AI code editor behaviour.

### Web search tool

The web search tool allows Claude to search for current or specialised information.

A typical schema includes:

```json
{
  "type": "web_search_20250305",
  "name": "web_search",
  "max_uses": 5,
  "allowed_domains": ["nih.gov"]
}
```

Useful features include:

* Multiple searches per request
* Domain restrictions
* Search result blocks
* Citation blocks
* Source-grounded answers

Domain restrictions are useful when quality matters. For example, medical or scientific queries can be restricted to trusted domains.

### Code execution and Files API

The Files API lets you upload files once and reference them by file ID in future requests.

Code execution allows Claude to run Python code in an isolated Docker container.

Important constraints:

* The container has no network access.
* Data must be provided through uploaded files.
* Claude can generate files such as plots or reports.

Typical flow:

```text
Upload file → Get file ID → Attach file to request → Claude writes/runs Python → Claude analyses results → Optional output files returned
```

Use cases include:

* Data analysis
* CSV processing
* Plot generation
* Report generation
* Complex file transformations

---

## 25. RAG: Retrieval-Augmented Generation

RAG is a technique for answering questions over large documents or collections of documents.

The problem: you may have hundreds or thousands of pages of content. Sending all of it to Claude is expensive, slow, and may exceed context limits.

RAG solves this by retrieving only relevant chunks.

### Direct document prompting

The simplest approach is to put the whole document in the prompt.

Benefits:

* Simple
* No preprocessing
* Easy to prototype

Limitations:

* Context limits
* Higher cost
* Slower requests
* Lower effectiveness on very long prompts

### RAG approach

RAG uses two steps:

1. Break documents into chunks.
2. Retrieve the most relevant chunks for each question.

Then only those chunks are included in the prompt.

Benefits:

* Scales to large document sets
* Reduces cost
* Improves focus
* Speeds up generation

Trade-off: more implementation complexity.

---

## 26. Chunking Strategies for RAG

Chunking quality has a major impact on RAG quality.

Bad chunking can make retrieval fail even if the answer exists in the source material.

### 1. Size-based chunking

Split text into fixed-size chunks.

Pros:

* Easy to implement
* Works with any text
* Common in production

Cons:

* Can cut sentences or concepts in half
* Loses context

A common improvement is overlap:

```text
Chunk 1: characters 0–1000
Chunk 2: characters 800–1800
Chunk 3: characters 1600–2600
```

Overlap duplicates some text but preserves continuity.

### 2. Structure-based chunking

Split by document structure:

* Markdown headings
* HTML sections
* Paragraphs
* Chapters
* Page sections

This is often better when source documents are well structured.

Example: split Markdown on `##` headings.

### 3. Semantic chunking

Semantic chunking groups sentences or sections based on meaning.

It is more advanced and can produce better chunks, but is more complex to implement.

### Rule of thumb

There is no universal best chunking strategy. Choose based on document type and retrieval requirements.

---

## 27. Embeddings and Semantic Search

Embeddings are numerical representations of text meaning.

An embedding model takes text and returns a vector: a long list of numbers.

```text
"software engineering incident response" → [0.12, -0.44, 0.03, ...]
```

Texts with similar meanings should have vectors that are close to one another.

### Semantic search flow

1. Generate embeddings for all document chunks.
2. Store them in a vector database.
3. Generate an embedding for the user query.
4. Search for the closest chunk vectors.
5. Add those chunks to the Claude prompt.

This enables meaning-based retrieval rather than simple keyword matching.

Anthropic commonly recommends using Voyage AI for embeddings, although many embedding providers can be used.

---

## 28. Full RAG Pipeline

A complete RAG pipeline usually looks like this:

1. Split documents into chunks.
2. Generate embeddings for each chunk.
3. Store embeddings in a vector database.
4. Receive a user query.
5. Generate an embedding for the query.
6. Search for similar vectors.
7. Assemble a prompt with retrieved context.
8. Send the prompt to Claude.
9. Return the grounded answer.

### Cosine similarity

A common similarity metric is cosine similarity.

* Closer to `1` means more similar.
* Cosine distance is often calculated as `1 - cosine_similarity`.
* Lower cosine distance means higher similarity.

### Minimal conceptual implementation

```python
chunks = chunk_document(document_text)
chunk_embeddings = generate_embeddings(chunks)

store = VectorIndex()

for chunk, embedding in zip(chunks, chunk_embeddings):
    store.add_vector(
        embedding,
        metadata={"content": chunk}
    )

query = "What did the software engineering team do last year?"
query_embedding = generate_embedding(query)

results = store.search(query_embedding, limit=3)

context = "\n\n".join(result.metadata["content"] for result in results)

prompt = f"""
Answer the question using the context below.

<context>
{context}
</context>

<question>
{query}
</question>
"""
```

---

## 29. BM25 and Hybrid Search

Semantic search is powerful, but it can miss exact terms.

BM25 is a lexical search algorithm that ranks documents based on keyword relevance.

It considers:

* Query terms
* Term frequency
* How rare terms are across the corpus
* Document relevance based on exact matches

Rare terms are usually more informative than common terms.

For example, in a technical corpus, the term “Kubernetes” is more useful than “the”.

### Hybrid search

A robust RAG system often combines:

* Vector search for semantic similarity
* BM25 for exact keyword matching

This improves retrieval when:

* User queries contain specific names
* Exact terms matter
* Acronyms are important
* Semantic search retrieves plausible but wrong chunks

---

## 30. Multi-Index RAG and Reciprocal Rank Fusion

A multi-index RAG pipeline uses more than one retrieval method.

Example:

```text
Query → Vector index
      → BM25 index
      → Merge results
      → Claude
```

### Reciprocal Rank Fusion

Reciprocal Rank Fusion merges ranked results from multiple search systems.

Formula:

```text
score = sum(1 / (rank + 1))
```

Example:

```text
Vector search: doc2, doc7, doc6
BM25 search:   doc6, doc2, doc7
```

RRF combines ranks so documents that perform well across search methods rise to the top.

Benefits:

* Better retrieval accuracy
* Modular design
* Easy to add more indexes
* Handles edge cases better than one retrieval method alone

---

## 31. Reranking Results

Reranking is a post-processing step.

First, retrieve candidate documents using vector search, BM25, or hybrid search. Then ask an LLM to reorder the candidates by relevance.

Flow:

```text
Retrieve candidates → Send query + candidates to Claude → Return ranked document IDs
```

To save tokens, pass document IDs and concise snippets rather than full documents.

Structured output can be enforced with prefill and stop sequences:

```json
{
  "ranked_document_ids": ["doc_2", "doc_6", "doc_7"]
}
```

Reranking improves quality, but adds latency because it requires another model call.

Use it when retrieval quality matters more than response speed.

---

## 32. Contextual Retrieval

When a document is chunked, each chunk loses some surrounding context. A chunk may refer to “this project”, “the incident”, or “the team” without explaining what those refer to.

Contextual retrieval solves this by adding generated context to each chunk before indexing.

### Process

1. Take the original document and one chunk.
2. Ask Claude to write brief context explaining where the chunk fits.
3. Prepend or append that context to the chunk.
4. Store the contextualised chunk in the vector and BM25 indexes.

Example:

```text
Context: This chunk is from the software engineering section of the 2023 annual report and describes incident response improvements.

Original chunk: The team reduced mean time to recovery by introducing automated rollback procedures...
```

This improves retrieval because the chunk now contains missing context.

For very large documents, include:

* The beginning of the document
* The chunks immediately before the target chunk
* The target chunk itself

This gives Claude enough context without sending the entire document.

---

## 33. Extended Thinking

Extended thinking gives Claude additional reasoning time before producing a final answer.

It is useful for complex tasks where normal prompting and evaluation are not enough.

Important constraints:

* Thinking tokens are charged.
* Thinking increases latency.
* The thinking budget has a minimum size.
* `max_tokens` must be greater than the thinking budget.

Example configuration concept:

```python
response = client.messages.create(
    model=model,
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 1024
    },
    messages=[
        {
            "role": "user",
            "content": "Analyse this complex architecture trade-off."
        }
    ]
)
```

Use extended thinking after normal prompt engineering fails to reach the required accuracy.

---

## 34. Image Support

Claude can process images in user messages.

Use cases include:

* Image description
* Counting objects
* Visual comparison
* UI analysis
* Diagram interpretation
* Risk assessment from satellite imagery

Images are included as special content blocks, either from base64 data or URLs depending on the API capability.

Example structure:

```python
message = {
    "role": "user",
    "content": [
        {
            "type": "image",
            "source": {
                "type": "base64",
                "media_type": "image/png",
                "data": base64_image
            }
        },
        {
            "type": "text",
            "text": "Analyse this image step by step."
        }
    ]
}
```

Prompt quality matters enormously for image tasks. Simple prompts often produce weak results.

Good image prompts include:

* Step-by-step inspection instructions
* Clear criteria
* Verification steps
* Examples when possible
* Required output format

---

## 35. PDF Support and Citations

Claude can read PDFs directly using document blocks.

The structure is similar to image input, but the type is `document` and the media type is `application/pdf`.

Claude can analyse:

* Text
* Tables
* Charts
* Images
* Mixed document content

### Citations

Citations allow Claude to reference where information came from.

Citation types include:

* Page-based citations for PDFs
* Character-location citations for text documents

To enable citations, include a citations setting on the document block and provide a title.

Citations are useful because they let users verify answers instead of trusting the model blindly.

For document-heavy applications, citations are critical for transparency.

---

## 36. Prompt Caching

Prompt caching improves speed and reduces cost by reusing processing work from previous requests.

Normally, every request is processed from scratch. If you send the same large system prompt, tool definitions, or document context repeatedly, that work is repeated each time.

Prompt caching stores processed input temporarily so identical content can be reused.

### Cache rules

Important rules:

* Cache duration is temporary, commonly up to one hour.
* You must add cache breakpoints manually.
* Content before the breakpoint must remain identical.
* Any change before the breakpoint invalidates that cache layer.
* Minimum cacheable content thresholds may apply.
* A limited number of breakpoints can be used per request.

### Longhand text blocks

To use cache control, you often need longhand content blocks:

```python
system = [
    {
        "type": "text",
        "text": "You are a helpful assistant for analysing legal contracts...",
        "cache_control": {"type": "ephemeral"}
    }
]
```

### Common cache locations

Good cache breakpoint candidates:

* Tool schemas
* Long system prompts
* Static document prefixes
* Repeated instruction blocks
* Stable conversation prefixes

The processing order is generally:

```text
Tools → System prompt → Messages
```

So tool schema caching is often especially useful.

---

## 37. MCP: Model Context Protocol

MCP is a protocol for connecting models to tools, resources, and prompts without every application having to implement custom integrations manually.

Instead of your application defining every tool schema and function, an MCP server exposes capabilities in a standard way.

### Architecture

```text
Your application → MCP client → MCP server → External service
```

An MCP server can expose:

* Tools
* Resources
* Prompts

This shifts integration work from every application developer to reusable MCP servers.

### Why MCP matters

Suppose you want Claude to interact with GitHub.

Without MCP, you might need to implement tools for:

* Listing repositories
* Reading files
* Creating issues
* Updating pull requests
* Searching commits
* Managing projects

With MCP, a GitHub MCP server can expose these capabilities for you.

MCP and tool use are complementary. Tool use is the model capability. MCP is a standard way to provide tools and context.

---

## 38. MCP Clients and Servers

An MCP client communicates with an MCP server.

Transport can vary:

* stdio
* HTTP
* WebSockets

A common local setup runs the client and server on the same machine using standard input/output.

### Typical MCP flow

1. User asks your application a question.
2. Your server asks the MCP client for available tools.
3. The MCP client sends a `list_tools` request to the MCP server.
4. The MCP server returns tool definitions.
5. Your server sends the user query and tools to Claude.
6. Claude requests a tool call.
7. Your server asks the MCP client to execute it.
8. The MCP client sends a `call_tool` request to the MCP server.
9. The MCP server executes the action.
10. Results flow back to Claude and then to the user.

---

## 39. Building MCP Tools

With the Python MCP SDK, tools can be defined using decorators instead of writing JSON schemas manually.

Example:

```python
from pydantic import Field

@mcp.tool(
    name="read_doc_contents",
    description="Read the contents of a document by ID."
)
def read_doc_contents(
    doc_id: str = Field(description="The ID of the document to read")
):
    if doc_id not in docs:
        raise ValueError(f"Document not found: {doc_id}")

    return docs[doc_id]
```

The SDK generates schemas from type hints and field descriptions.

A second tool might edit a document:

```python
@mcp.tool(
    name="edit_document",
    description="Replace a string inside a document."
)
def edit_document(
    doc_id: str,
    old_string: str,
    new_string: str
):
    if doc_id not in docs:
        raise ValueError(f"Document not found: {doc_id}")

    docs[doc_id] = docs[doc_id].replace(old_string, new_string)
    return "Document updated"
```

---

## 40. MCP Resources

Resources expose data for read operations.

There are two common types:

### Direct resources

Static URI:

```text
docs://documents
```

### Templated resources

Parameterized URI:

```text
docs://documents/{doc_id}
```

Resources are useful when the client wants to fetch context proactively, rather than waiting for Claude to request a tool.

Example:

```python
@mcp.resource("docs://documents/{doc_id}", mime_type="text/plain")
def read_document_resource(doc_id: str):
    return docs[doc_id]
```

The client reads resources by URI and parses them based on MIME type.

---

## 41. MCP Prompts

MCP servers can also expose predefined prompt templates.

This is useful because server authors often know the best way to use their tools.

Example use case: a document server exposes a prompt called `format_document_as_markdown`.

The prompt might instruct Claude to:

1. Read a document using available tools.
2. Convert it to Markdown.
3. Save the updated version.

Clients can list available prompts and invoke them with arguments.

Conceptual client flow:

```python
prompts = await session.list_prompts()
messages = await session.get_prompt(
    "format_document_as_markdown",
    arguments={"document_id": "doc_123"}
)
```

The returned messages can be sent directly to Claude.

---

## 42. Claude Code

Claude Code is a terminal-based coding assistant. It is useful as a practical example of agent architecture.

It can:

* Search files
* Read files
* Edit files
* Run terminal commands
* Help set up projects
* Write tests
* Debug issues
* Work with Git
* Connect to MCP servers

### Effective Claude Code workflow

A strong workflow is:

1. Ask Claude to inspect relevant files.
2. Ask it to propose a plan without coding yet.
3. Review the plan.
4. Ask it to implement.
5. Ask it to run tests.
6. Ask it to commit changes.

Another useful workflow is test-driven:

1. Provide context.
2. Ask Claude to suggest tests.
3. Select tests.
4. Ask Claude to implement until tests pass.

Claude Code is most effective when treated as a collaborative engineer, not a one-shot code generator.

### Project memory

Claude Code can create a `claude.md` file after scanning a project. This file stores project-specific context such as architecture, style, and conventions.

You can also add notes to memory so future requests have more context.

---

## 43. Enhancing Claude Code with MCP Servers

Claude Code includes an MCP client. That means you can connect it to custom MCP servers.

Example command:

```bash
claude mcp add document-server "uv run main.py"
```

After restarting Claude Code, the new server capabilities become available.

Use cases include:

* Sentry integration
* Jira integration
* Slack integration
* Custom document processing
* Internal deployment tools
* Production monitoring

This allows Claude Code to gain new capabilities without changing its core implementation.

---

## 44. Parallelising Claude Code with Git Worktrees

Running multiple Claude Code instances on the same repository can cause conflicts if they edit the same files.

Git worktrees solve this by creating isolated working directories tied to different branches.

Workflow:

```text
Create worktree → Start Claude instance → Assign task → Commit changes → Merge branch → Remove worktree
```

This lets one developer manage multiple AI coding agents in parallel.

You can also create custom Claude commands in `.claude/commands` using Markdown files and `$ARGUMENTS` placeholders.

Parallelism is powerful, but the bottleneck becomes the developer’s ability to review and coordinate the work.

---

## 45. Automated Debugging

Claude can be integrated into automated debugging workflows.

Example daily production debugging workflow:

1. GitHub Action runs every day.
2. It fetches CloudWatch logs from the last 24 hours.
3. Claude identifies errors and deduplicates them.
4. Claude analyses likely causes.
5. Claude proposes fixes.
6. Claude Code creates a pull request.

This is valuable for catching production-only issues such as:

* Environment-specific configuration errors
* Invalid model IDs
* Missing API keys
* Deployment-only runtime failures

The key benefit is not automatic merging. The key benefit is a reviewable pull request with context and proposed fixes.

---

## 46. Computer Use

Computer use allows Claude to interact with graphical interfaces through screenshots and actions.

Claude can:

* Take screenshots
* Move the mouse
* Click
* Type
* Navigate applications
* Test web interfaces
* Report results

The important point: Claude does not directly control your computer. It requests tool actions, and an execution environment performs them.

Typical implementation:

```text
User instruction → Claude observes screenshot → Claude requests click/type action → Container executes action → Screenshot returned → Claude continues
```

Computer use is useful for:

* UI testing
* QA automation
* Browser workflows
* Repetitive interface tasks
* Bug discovery

It relies heavily on environment inspection. After every action, Claude needs to observe the new state to decide what to do next.

---

## 47. Workflows vs Agents

A workflow is a predefined sequence of steps.

An agent dynamically decides what steps to take using available tools.

### Use workflows when the steps are known

Workflows are more reliable, easier to test, and easier to optimise.

Example: image-to-3D-model workflow.

1. Claude describes the image.
2. Claude writes CADQuery code.
3. The system renders the model.
4. Claude compares render to source image.
5. If needed, repeat with feedback.

This is an evaluator-optimizer workflow.

### Use agents when the steps are unknown

Agents are useful when tasks vary and the model must decide how to proceed.

Agents need tools, feedback, and environment inspection.

Good agent tools are usually abstract rather than overly specific:

* `bash`
* `read_file`
* `write_file`
* `web_fetch`
* `get_current_datetime`
* `add_duration`
* `set_reminder`

Avoid creating only hyper-specific tools like `install_dependencies_for_react_project`, because generic tools compose better.

---

## 48. Workflow Patterns

Several workflow patterns are useful when building Claude applications.

### Chaining

Break a large task into sequential steps.

Example:

```text
Topic → Research → Outline → Draft → Rewrite for constraints → Final output
```

This helps when a single long prompt causes Claude to miss constraints.

### Parallelisation

Split a decision into independent subtasks, run them in parallel, then aggregate.

Example: choosing a material for a part.

```text
Evaluate metal
Evaluate polymer
Evaluate ceramic
Evaluate composite
→ Aggregate recommendation
```

Each subtask gets focused attention.

### Routing

First classify the input, then route to a specialised prompt or pipeline.

Example:

```text
User topic → classify as educational / entertainment / technical → use matching script template
```

Routing is useful when different inputs require different tones, tools, or structures.

### Evaluator-optimizer

Generate an output, evaluate it, then improve it.

Example:

```text
Generate answer → Check constraints → Rewrite violations → Final answer
```

This pattern is very useful for quality control.

---

## 49. Environment Inspection for Agents

Agents need feedback.

After taking an action, they must inspect the result.

Examples:

* A computer-use agent takes screenshots after clicks.
* A coding agent reads files before editing.
* A video-generation agent extracts frames with FFmpeg to inspect visual output.
* A captioning agent checks timestamps after running Whisper.

Without environment inspection, agents act blindly. With inspection, they can detect errors and adapt.

This is one of the main differences between a simple tool call and a robust agent loop.

---

## 50. Practical Architecture Recommendations

A reliable Claude application usually combines several patterns.

### Start simple

Begin with:

* One model
* Clear prompt
* Basic message history
* Simple API wrapper

### Add structure

Then add:

* System prompts
* Output formatting rules
* Stop sequences or structured tool extraction
* Prompt evaluations

### Add tools

When Claude needs external data or actions, add tools:

* Current time
* Database search
* Internal APIs
* File access
* Web search
* Code execution

### Add retrieval

When the knowledge base grows, add RAG:

* Chunking
* Embeddings
* Vector search
* BM25
* Reranking
* Contextual retrieval

### Add workflows before agents

If you know the steps, build a workflow. It will be more reliable.

Use agents only when flexibility is truly required.

---

## Conclusion

Building with Claude is not only about sending a prompt and reading a response. A production-grade Claude application involves architecture decisions around models, prompts, state, streaming, tool execution, structured outputs, evaluations, retrieval, caching, MCP integrations, and agent design.

The most important principle is reliability. Start with the simplest architecture that works, evaluate it systematically, and only add advanced patterns when they solve a real problem.

Use:

* **Sonnet** as the default model for most production use cases.
* **Haiku** for speed, routing, classification, and high-volume tasks.
* **Opus** for the hardest reasoning and planning tasks.
* **Prompt evaluations** before shipping prompts.
* **Tools** when Claude needs external data or actions.
* **RAG** when knowledge is too large for direct prompting.
* **MCP** when you want reusable integrations.
* **Workflows** when the process is known.
* **Agents** when the process must be discovered dynamically.

The best Claude systems are not just clever prompts. They are well-designed software systems where the model, tools, data, and control flow work together.


