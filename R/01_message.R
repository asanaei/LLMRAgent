    
    #' Create a chat message
    #'
    #' Minimal S3 message object used by agents and tools.
    #'
    #' @param role One of 'system', 'user', or 'assistant'.
    #' @param content Message text (length-one character).
    #' @param name Optional author name.
    #' @param tool_calls Optional list of tool call records.
    #' @param tool_call_id Optional id for tool response messages.
    #' @return An object of class `llmr_agent_message`.
    #' @examples
    #' msg <- create_message("user", "hello")
    #' @export
    create_message <- function(role = "user", content = "", name = NULL,
                               tool_calls = NULL, tool_call_id = NULL) {
      stopifnot(role %in% c("system", "user", "assistant"))
      stopifnot(length(content) == 1L)
      structure(
        purrr::compact(list(
          role       = role,
          content    = as.character(content)[1],
          name       = name,
          tool_calls = tool_calls,
          tool_call_id = tool_call_id,
          timestamp  = Sys.time()
        )),
        class = "llmr_agent_message"
      )
    }

    #' Format messages for LLM API calls
    #'
    #' Strips non-standard fields and returns a data structure commonly
    #' accepted by LLM chat APIs.
    #' @param msg_list A list of `llmr_agent_message` objects.
    #' @return A list suitable for API submission.
    #' @examples
    #' msgs <- list(create_message("user","hi"))
    #' format_messages_for_api(msgs)
    #' @export
    format_messages_for_api <- function(msg_list) {
      stopifnot(is.list(msg_list))
      lapply(msg_list, function(m) {
        list(
          role = m$role,
          content = m$content,
          name = m$name %||% NULL
        )
      })
    }
