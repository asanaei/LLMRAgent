    
    #' Save an agent to disk
    #'
    #' Persists system prompt, memory messages, usage history and counters, and model_config.
    #' Uses RDS serialization.
    #'
    #' @param agent Agent environment created by `new_agent()`.
    #' @param path File path to save as `.rds`.
    #' @return Invisibly, the path.
    #' @examples
    #' \dontrun{
    #'   cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = "key")
    #'   ag <- new_agent("Be brief.", cfg)
    #'   save_agent(ag, tempfile(fileext = ".rds"))
    #' }
    #' @export
    save_agent <- function(agent, path) {
      stopifnot(is.environment(agent))
      obj <- list(
        system_prompt = agent$system_prompt,
        memory_messages = tryCatch(agent$memory$get(), error = function(e) list()),
        usage_history = agent$usage_history %||% list(),
        total_tokens_in = agent$total_tokens_in %||% 0,
        total_tokens_out = agent$total_tokens_out %||% 0,
        total_tokens = agent$total_tokens %||% 0,
        model_config = agent$model_config
      )
      saveRDS(obj, file = path)
      invisible(path)
    }
    
    #' Load an agent from disk
    #'
    #' Reconstructs an agent from a file saved by `save_agent()`.
    #' Restores memory and usage counters; requires `LLMR` to be available for `new_agent()`.
    #'
    #' @param path Path to `.rds` file created by `save_agent()`.
    #' @return Agent environment.
    #' @examples
    #' \dontrun{
    #'   ag2 <- load_agent("agent_state.rds")
    #' }
    #' @export
    load_agent <- function(path) {
      obj <- readRDS(path)
      # capacity: keep at least length(messages), else default 10
      cap <- max(length(obj$memory_messages %||% list()), 10)
      mem <- new_buffer_memory(cap)
      for (m in obj$memory_messages) mem$add(m)
      ag <- new_agent(
        system_prompt = obj$system_prompt %||% "",
        model_config = obj$model_config,
        memory = mem
      )
      ag$usage_history <- obj$usage_history %||% list()
      ag$total_tokens_in <- obj$total_tokens_in %||% 0
      ag$total_tokens_out <- obj$total_tokens_out %||% 0
      ag$total_tokens <- obj$total_tokens %||% 0
      ag
    }

