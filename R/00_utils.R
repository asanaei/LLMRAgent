    
    #' Internal Utilities
    #'
    #' @keywords internal
    #' @noRd
    `%||%` <- function(x, y) if (is.null(x)) y else x

    #' Internal logger
    #' @keywords internal
    #' @noRd
    .rl <- function(...) {
      msg <- paste0("[LLMRAgent] ", paste0(..., collapse = ""))
      message(msg)
    }

    #' Validate that an object is JSON-serializable
    #' @param x any
    #' @return logical
    #' @keywords internal
    #' @noRd
    check_json <- function(x) {
      out <- try(jsonlite::toJSON(x, auto_unbox = TRUE), silent = TRUE)
      if (inherits(out, "try-error")) return(FALSE)
      isTRUE(jsonlite::validate(out))
    }

    #' Estimate tokens (very rough character-based heuristic)
    #' @param text character
    #' @return integer approximate tokens
    #' @keywords internal
    #' @noRd
    token_est <- function(text) {
      if (length(text) == 0 || is.null(text)) return(0L)
      as.integer(nchar(paste(text, collapse = " ")) / 4)
    }

    #' Call LLM with JSON guard
    #' @keywords internal
    #' @noRd
    .call_llm_guarded <- function(config, messages, json_flag = TRUE) {
      jf <- isTRUE(json_flag)
      res <- try(LLMR::call_llm_robust(config = config, messages = messages, json = jf), silent = TRUE)
      if (inherits(res, "try-error") && jf) {
        .rl("call_llm_robust failed with json=TRUE; retrying with json=FALSE")
        res <- LLMR::call_llm_robust(config = config, messages = messages, json = FALSE)
      }
      res
    }
