## Memory and Conversation Demo with OpenAI
## Requires OPENAI_API_KEY environment variable
## Run: source(system.file("examples", "04_memory_and_conversation.R", package = "LLMR.Agent"))

library(LLMR)
library(LLMR.Agent)

# Check for API key
if (Sys.getenv("OPENAI_API_KEY") == "") {
  stop("Please set OPENAI_API_KEY environment variable")
}

# Create LLMR config
config <- LLMR::llm_config(
  provider = "openai",
  model = "gpt-4o-mini",
  api_key = Sys.getenv("OPENAI_API_KEY")
)

# Create agent with custom memory buffer size
agent <- new_agent(
  system_prompt = "You are a friendly assistant who remembers our conversation. Be concise.",
  model_config = config,
  memory = new_buffer_memory(5)  # Keep last 5 messages
)

cat("Starting conversation with memory-enabled agent:\n\n")

# Turn 1
reply1 <- agent_reply(agent, "Hi, my name is Alice.")
cat("User: Hi, my name is Alice.\n")
cat("Agent:", reply1, "\n\n")

# Turn 2
reply2 <- agent_reply(agent, "What's my name?")
cat("User: What's my name?\n")
cat("Agent:", reply2, "\n\n")

# Turn 3
reply3 <- agent_reply(agent, "I like programming in R.")
cat("User: I like programming in R.\n")
cat("Agent:", reply3, "\n\n")

# Turn 4
reply4 <- agent_reply(agent, "What did I say I like?")
cat("User: What did I say I like?\n")
cat("Agent:", reply4, "\n\n")

# Check memory contents
cat("Current memory contains", length(agent$memory$get()), "messages:\n")
for(i in seq_along(agent$memory$get())) {
  msg <- agent$memory$get()[[i]]
  cat(sprintf("%d. [%s]: %s\n", i, msg$role, substr(msg$content, 1, 50)))
}
