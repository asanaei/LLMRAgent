## LLMR Integration Example (requires API key)
## Run: source(system.file("examples", "02_llmr_integration.R", package = "LLMRAgent"))

library(LLMRAgent)

# Check if LLMR is available
if (requireNamespace("LLMR", quietly = TRUE)) {

  # Example with OpenAI (requires API key)
  if (Sys.getenv("OPENAI_API_KEY") != "") {
    config <- LLMR::llm_config(
      provider = "openai",
      model = "gpt-4o-mini",  # Use cheaper model for demo
      api_key = Sys.getenv("OPENAI_API_KEY")
    )

    agent <- new_agent(
      system_prompt = "You are a helpful assistant. Be concise.",
      model_config = config
    )

    cat("Created agent with OpenAI config\n")

    # Use JSON mode for structured responses
    reply <- agent_reply(agent, "Tell me about R programming in one sentence", json = FALSE)
    cat("Agent reply:\n", reply, "\n", sep = "")

  } else {
    cat("OPENAI_API_KEY not set. Skipping OpenAI example.\n")
  }

  # Example with Anthropic (requires API key)
  if (Sys.getenv("ANTHROPIC_API_KEY") != "") {
    config <- LLMR::llm_config(
      provider = "anthropic",
      model = "claude-3-haiku-20240307",
      api_key = Sys.getenv("ANTHROPIC_API_KEY")
    )

    agent <- new_agent(
      system_prompt = "You are a helpful assistant. Be very brief.",
      model_config = config
    )

    cat("\nCreated agent with Anthropic config\n")
    reply <- agent_reply(agent, "What is the capital of France?", json = FALSE)
    cat("Agent reply:\n", reply, "\n", sep = "")

  } else {
    cat("ANTHROPIC_API_KEY not set. Skipping Anthropic example.\n")
  }

} else {
  cat("LLMR package not available. Install it to use model integrations.\n")
}

