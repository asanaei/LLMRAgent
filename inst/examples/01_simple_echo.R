## Simple Agent Example with OpenAI
## Requires OPENAI_API_KEY environment variable
## Run: source(system.file("examples", "01_simple_echo.R", package = "LLMRAgent"))

library(LLMR)
library(LLMRAgent)

# Check for API key
if (Sys.getenv("OPENAI_API_KEY") == "") {
  stop("Please set OPENAI_API_KEY environment variable")
}

# Create LLMR config
config <- LLMR::llm_config(
  provider = "openai",
  model = "gpt-4.1-nano",  # Use cheaper model for demo
  api_key = Sys.getenv("OPENAI_API_KEY")
)

# Create agent with config
agent <- new_agent(
  system_prompt = "You are a helpful assistant.
  Whatever you here, you summarize and repeat
  in a language that 8 year olds understand",
  model_config = config
)

# Single interaction
reply <- agent_reply(agent, "Hello, what can you do?")
cat("Agent reply:\n", reply, "\n\n", sep = "")


# Second interaction
reply2 <- agent_reply(agent, "Tell me a short joke")
cat("Second reply:\n", reply2, "\n", sep = "")


# Third interaction
reply3 <- agent_reply(agent, "What does an aileron do?")
cat("Second reply:\n", reply3, "\n", sep = "")

agent$total_tokens
agent$system_prompt
agent$usage_history[[3]]$reply_text
agent$memory$messages
agent$total_tokens_out
agent$total_tokens_in
