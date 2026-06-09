import { SaarLabs } from "@saarlabs/api";

const saar = new SaarLabs({
apiKey: "[ENCRYPTION_KEY]"
});

// Stream the response to get reasoning tokens in usage
const stream = await saar.chat.send({
model: "gpt-4o", //auto by default
persona: "broker",
messages: [
{
role: "user",
content: "What is the stock price of Tesla?"
}
],
tools:[
{
type: "web_search",
description: "Search the web",
}
],
stream: true
});

let response = "";
for await (const chunk of stream) {
const content = chunk.choices[0]?.delta?.content;
if (content) {
response += content;
process.stdout.write(content);
}

// Usage information comes in the final chunk
if (chunk.usage) {
console.log("\nReasoning tokens:", chunk.usage.reasoningTokens);
}
}

curl -N https://saarlabs.ai/api/v1/chat/completions \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $SAARLABS_API_KEY" \
 -d '{
"model": "gpt-5.1",
"persona": "support",
"tools": [
"web_search",
"google_search",
"wikipedia_search",
"youtube_search",
"pdf_reader",
"document_explorer",
"context_aware_browser",
"code_interpreter",
"code_execution_sandbox",
"filesystem_accessor",
"custom_api",
"database_query"
],
"stream": true,
"messages": [
{"role": "user", "content": "What is the stock price of Tesla?"}
]
}'
