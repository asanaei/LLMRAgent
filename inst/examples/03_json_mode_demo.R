## JSON Mode Demo (requires API key)
## Run: source(system.file("examples", "03_json_mode_demo.R", package = "LLMRAgent"))

library(LLMRAgent)

if (requireNamespace("LLMR", quietly = TRUE)) {

  # Example with JSON mode enabled
  if (Sys.getenv("OPENAI_API_KEY") != "") {
    config <- LLMR::llm_config(
      provider = "openai",
      model = "gpt-4o-mini",
      api_key = Sys.getenv("OPENAI_API_KEY")
    )

    agent <- new_agent(
      system_prompt = "You are a data analyst. Always respond with structured data in JSON format.",
      model_config = config
    )

    cat("Testing JSON mode with structured data request:\n")

    # Request structured data with JSON mode
    reply <- agent_reply(
      agent,
      "Give me information about the programming language R: name, year created, and main use case. Format as JSON.",
      json = TRUE
    )

    cat("JSON Response:\n", reply, "\n", sep = "")

    # Try to parse the JSON
    tryCatch({
      parsed <- jsonlite::fromJSON(reply)
      cat("\nSuccessfully parsed JSON:\n")
      print(parsed)
    }, error = function(e) {
      cat("\nNote: Response may not be valid JSON:", e$message, "\n")
    })

  } else {
    cat("OPENAI_API_KEY not set. Set it to test JSON mode.\n")
  }

} else {
  cat("LLMR package not available. Install it to use JSON mode.\n")
}
