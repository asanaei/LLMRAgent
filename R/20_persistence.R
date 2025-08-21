
#' Save an agent to disk
#'
#' Persists system prompt, memory messages, usage history and counters, and
#' model_config.
#' Uses RDS serialization.
#'
#' @param agent Agent object created by `new_agent()`
#' @param path File path to write `.rds`
#' @return Invisible `path`
#' @examplesIf nzchar(Sys.getenv("OPENAI_API_KEY")) && identical(Sys.getenv("LLMRAgent_RUN_EXAMPLES"), "true")
#'   cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini",
#'                       api_key = Sys.getenv("OPENAI_API_KEY"))
#'   ag <- new_agent("Be brief.", cfg)
#'   save_agent(ag, tempfile(fileext = ".rds"))
#' @export
save_agent <- function(agent, path) {
  stopifnot(is.environment(agent))
  cfg <- agent$model_config
  if (!is.null(cfg$api_key)) {
    cfg$api_key <- "<redacted>"
  }
  obj <- list(
    system_prompt    = agent$system_prompt,
    memory_messages  = tryCatch(agent$memory$get(), error = function(e) list()),
    usage_history    = agent$usage_history %||% list(),
    total_tokens_in  = agent$total_tokens_in %||% 0L,
    total_tokens_out = agent$total_tokens_out %||% 0L,
    total_tokens     = agent$total_tokens %||% 0L,
    model_config     = cfg
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

