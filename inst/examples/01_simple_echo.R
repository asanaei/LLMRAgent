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
  model = "gpt-4o-mini",  # Use cheaper model for demo
  api_key = Sys.getenv("OPENAI_API_KEY")
)

# Create agent with config
agent <- new_agent(
  system_prompt = "Be brief and helpful.",
  model_config = config
)

# Single interaction
reply <- agent_reply(agent, "Hello, what can you do?")
cat("Agent reply:\n", reply, "\n\n", sep = "")

# Second interaction
reply2 <- agent_reply(agent, "Tell me a short joke")
cat("Second reply:\n", reply2, "\n", sep = "")

