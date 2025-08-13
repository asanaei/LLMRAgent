    
    #' Create Agent with Model Config
    #'
    #' Simple agent that uses LLMR model configuration directly.
    #' Automatically tracks token usage across all interactions.
    #' Requires a valid LLMR model config to function.
    #'
    #' @param system_prompt System message to prepend.
    #' @param model_config LLMR model config from `LLMR::llm_config()`. Required.
    #' @param memory Memory object from `new_buffer_memory()` or `new_summary_memory()`.
    #' @param summarizer_model_config Optional LLMR config used by summary memory.
    #'   If `NULL` and `memory` is a summary memory without its own config, defaults to `model_config`.
    #' @return An agent environment with built-in usage tracking.
    #' @examples
    #' if (requireNamespace("LLMR", quietly = TRUE) && Sys.getenv("OPENAI_API_KEY") != "") {
    #'   config <- LLMR::llm_config(provider = "openai", model = "gpt-4", 
    #'                              api_key = Sys.getenv("OPENAI_API_KEY"))
    #'   ag <- new_agent(system_prompt = "Be brief.", model_config = config)
    #'   # agent_reply(ag, "Hello")
    #'   # usage <- agent_usage(ag)  # Check token usage
    #' }
    #' @seealso [agent_reply()], [agent_usage()], [agent_usage_reset()]
    #' @export
    new_agent <- function(system_prompt = "", model_config, memory = new_buffer_memory(10),
                          summarizer_model_config = NULL) {
      if (missing(model_config) || is.null(model_config)) {
        stop("model_config is required. Use LLMR::llm_config() to create one.")
      }
      
      if (!requireNamespace("LLMR", quietly = TRUE)) {
        stop("Package 'LLMR' is required. Please install it.")
      }
      
      env <- new.env(parent = emptyenv())
      env$system_prompt <- as.character(system_prompt)[1]
      env$memory <- memory
      env$model_config <- model_config
      # If memory is a summary memory and lacks config, set a default summarizer config
      if (inherits(env$memory, "llmr_summary_memory")) {
        default_sum_cfg <- summarizer_model_config %||% model_config
        # use accessor if available, else set field
        if (is.null(env$memory$model_config)) {
          if (is.function(env$memory$set_config)) env$memory$set_config(default_sum_cfg) else env$memory$model_config <- default_sum_cfg
        }
      }
      # Convenience setter for summarizer config if memory supports it
      env$set_summarizer_config <- function(cfg) {
        if (inherits(env$memory, "llmr_summary_memory")) {
          if (is.function(env$memory$set_config)) env$memory$set_config(cfg) else env$memory$model_config <- cfg
          invisible(TRUE)
        } else {
          stop("Current memory does not support summarizer configuration.")
        }
      }
      env$usage_history <- list()
      env$total_tokens_in <- 0
      env$total_tokens_out <- 0
      env$total_tokens <- 0
      env
    }

    #' Ask the agent to reply
    #'
    #' Uses LLMR directly with the agent's model config.
    #' Automatically tracks token usage in the agent.
    #'
    #' @param agent Agent created by `new_agent()`.
    #' @param user_text User message.
    #' @param json Whether to use JSON mode (default TRUE if model supports it).
    #' @seealso [new_agent()], [format_messages_for_api()], [agent_usage()]
    #' @return character assistant reply.
    #' @examples
    #' if (requireNamespace("LLMR", quietly = TRUE) && Sys.getenv("OPENAI_API_KEY") != "") {
    #'   config <- LLMR::llm_config(provider = "openai", model = "gpt-4",
    #'                              api_key = Sys.getenv("OPENAI_API_KEY"))
    #'   ag <- new_agent(system_prompt = "Be brief.", model_config = config)
    #'   # reply <- agent_reply(ag, "hello")
    #'   # usage <- agent_usage(ag)  # Get cumulative usage
    #' }
    #' @export
    agent_reply <- function(agent, user_text, json = TRUE) {
      stopifnot(is.environment(agent))
      
      msgs <- list()
      if (nzchar(agent$system_prompt)) {
        msgs <- c(msgs, list(create_message("system", agent$system_prompt)))
      }
      user_msg <- create_message("user", user_text)
      msgs <- c(msgs, agent$memory$get(), list(user_msg))
      
      # Use LLMR directly with model config
      resp <- LLMR::call_llm_robust(
        config = agent$model_config,
        messages = format_messages_for_api(msgs),
        json = json
      )
      
      # Handle different response formats from LLMR
      reply_text <- if (is.character(resp)) {
        resp[1]
      } else if (is.list(resp) && !is.null(resp$text)) {
        as.character(resp$text)[1]
      } else if (is.list(resp) && !is.null(resp$content)) {
        as.character(resp$content)[1]
      } else {
        as.character(resp)[1]
      }
      
      if (!nzchar(reply_text)) reply_text <- ""
      
      # Track usage information if available
      if (is.list(resp)) {
        tokens_in <- resp$tokens_in %||% resp$input_tokens %||% 0
        tokens_out <- resp$tokens_out %||% resp$output_tokens %||% 0
        tokens_total <- resp$tokens_total %||% resp$total_tokens %||% (tokens_in + tokens_out)
        
        # Update agent totals
        agent$total_tokens_in <- agent$total_tokens_in + tokens_in
        agent$total_tokens_out <- agent$total_tokens_out + tokens_out  
        agent$total_tokens <- agent$total_tokens + tokens_total
        
        # Add to usage history
        usage_record <- list(
          timestamp = Sys.time(),
          tokens_in = tokens_in,
          tokens_out = tokens_out,
          tokens_total = tokens_total,
          finish_reason = resp$finish_reason %||% NA,
          model = resp$model %||% NA,
          user_text = substr(user_text, 1, 100), # First 100 chars for reference
          reply_text = substr(reply_text, 1, 100)
        )
        agent$usage_history <- append(agent$usage_history, list(usage_record))
      }
      
      out_msg <- create_message("assistant", reply_text)
      agent$memory$add(user_msg)
      agent$memory$add(out_msg)
      reply_text
    }

    #' Get agent's cumulative token usage
    #'
    #' Returns the total token usage for this agent across all interactions.
    #' 
    #' @param agent Agent created by `new_agent()`.
    #' @return List with components:
    #'   \item{total_tokens_in}{Cumulative input tokens}
    #'   \item{total_tokens_out}{Cumulative output tokens}  
    #'   \item{total_tokens}{Cumulative total tokens}
    #'   \item{interactions}{Number of interactions}
    #'   \item{history}{List of interaction records with timestamps and token details}
    #' @examples
    #' if (requireNamespace("LLMR", quietly = TRUE) && Sys.getenv("OPENAI_API_KEY") != "") {
    #'   config <- LLMR::llm_config(provider = "openai", model = "gpt-4",
    #'                              api_key = Sys.getenv("OPENAI_API_KEY"))
    #'   ag <- new_agent(system_prompt = "Be brief.", model_config = config)
    #'   # agent_reply(ag, "hello")
    #'   # usage <- agent_usage(ag)
    #'   # cat("Total tokens used:", usage$total_tokens)
    #'   # cat("Interactions:", usage$interactions)
    #' }
    #' @seealso [agent_reply()], [agent_usage_reset()]
    #' @export
    agent_usage <- function(agent) {
      stopifnot(is.environment(agent))
      list(
        total_tokens_in = agent$total_tokens_in,
        total_tokens_out = agent$total_tokens_out,
        total_tokens = agent$total_tokens,
        interactions = length(agent$usage_history),
        history = agent$usage_history
      )
    }

    #' Reset agent's token usage tracking
    #'
    #' Clears the usage history and resets counters to zero.
    #' 
    #' @param agent Agent created by `new_agent()`.
    #' @return Nothing (invisibly).
    #' @examples
    #' if (requireNamespace("LLMR", quietly = TRUE) && Sys.getenv("OPENAI_API_KEY") != "") {
    #'   config <- LLMR::llm_config(provider = "openai", model = "gpt-4",
    #'                              api_key = Sys.getenv("OPENAI_API_KEY"))
    #'   ag <- new_agent(system_prompt = "Be brief.", model_config = config)
    #'   # agent_reply(ag, "hello")  
    #'   # agent_usage_reset(ag)  # Clear usage history
    #' }
    #' @export
    agent_usage_reset <- function(agent) {
      stopifnot(is.environment(agent))
      agent$usage_history <- list()
      agent$total_tokens_in <- 0
      agent$total_tokens_out <- 0
      agent$total_tokens <- 0
      invisible(NULL)
    }
