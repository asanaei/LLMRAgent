    
    #' Memory Interfaces
    #'
    #' Minimal memory implementations. BufferMemory keeps the last `n` messages.
    #' @name memory-api
    NULL

    #' Create a new BufferMemory
    #'
    #' @param n Number of most recent messages to keep.
    #' @return Buffer memory object.
    #' @examples
    #' mem <- new_buffer_memory(3)
    #' mem$add(create_message("user","hi"))
    #' @export
    new_buffer_memory <- function(n = 10) {
      stopifnot(is.numeric(n), n >= 1)
      env <- new.env(parent = emptyenv())
      env$n <- as.integer(n)
      env$messages <- list()
      env$add <- function(msg) {
        stopifnot(inherits(msg, "llmr_agent_message"))
        env$messages <- c(env$messages, list(msg))
        if (length(env$messages) > env$n) {
          env$messages <- utils::tail(env$messages, env$n)
        }
        invisible(TRUE)
      }
      env$get <- function() env$messages
      env$reset <- function() {
        env$messages <- list()
        invisible(TRUE)
      }
      class(env) <- c("llmr_buffer_memory", class(env))
      env
    }

    #' Summary Memory (stub)
    #'
    #' A conservative interface for future summarising memory. This stub intentionally
    #' avoids calling any external LLMs. Methods emit a warning when not implemented.
    #'
    #' @param ... Reserved for future use.
    #' @return An environment with a stable interface: `$add(msg)`, `$get()`, `$summary()`.
    #' @examples
    #' sm <- new_summary_memory()
    #' sm$add(create_message("user","hello"))
    #' sm$summary()
    #' @seealso [new_buffer_memory()], [memory-api]
    #' @export
    new_summary_memory <- function(...) {
      env <- new.env(parent = emptyenv())
      env$messages <- list()
      env$add <- function(msg) {
        stopifnot(inherits(msg, "llmr_agent_message"))
        env$messages <- c(env$messages, list(msg))
        invisible(TRUE)
      }
      env$get <- function() env$messages
      env$summary <- function() {
        warning("SummaryMemory is not implemented yet; returning last user message.")
        last_user <- rev(purrr::keep(env$messages, ~ .x$role == "user"))
        if (length(last_user)) last_user[[1]]$content else ""
      }
      class(env) <- c("llmr_summary_memory", class(env))
      env
    }
