    
    #' Internal Utilities
    #'
    #' @keywords internal
    #' @noRd
    `%||%` <- function(x, y) if (is.null(x)) y else x

    #' Internal logger
    #' @keywords internal
    #' @noRd
    .rl <- function(...) {
      msg <- paste0("[LLMR.Agent] ", paste0(..., collapse = ""))
      message(msg)
    }

    #' Validate that an object is JSON-serializable
    #' @param x any
    #' @return logical
    #' @keywords internal
    #' @noRd
    check_json <- function(x) {
      out <- try(jsonlite::toJSON(x, auto_unbox = TRUE), silent = TRUE)
      !inherits(out, "try-error")
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
