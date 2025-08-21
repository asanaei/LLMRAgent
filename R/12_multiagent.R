
    #' Simple Multi-Agent Orchestrator
    #'
    #' Conservatively coordinates a small set of agents in a round-robin loop.
    #' No tool/function-calling is performed. A termination function and step
    #' function are injectable for deterministic testing and custom policies.
    #'
    #' @param participants List of participants of the form list(list(role, agent), ...).
    #'   Each `agent` is created by `new_agent()`. `role` is a string used in transcripts.
    #' @param termination_fn Function taking the current transcript (list of messages)
    #' and returning TRUE when the session should stop. Defaults to
    #' `final_keyword_termination("\[FINAL\]")`.
    #' @param max_turns Maximum total agent turns (safety bound). Default 6.
    #' @param step_fn Function called as `step_fn(agent, input_text)` returning
    #' a character reply.
    #'   Defaults to calling `agent_reply(agent, input_text, json = FALSE)`.
    #' @return An environment with methods: `$run(initial_user_text)`, `$transcript()`.
    #' @examples
    #' # Deterministic test-style use (no API calls):
    #' dummy <- new.env(); dummy$memory <- new_buffer_memory(2)
    #' dummy$system_prompt <- ""
    #' dummy$model_config <- list()
    #' orchestrator <- new_multiagent_orchestrator(
    #'   participants = list(list(role = "assistant", agent = dummy),
    #'   list(role = "critic", agent = dummy)),
    #'   step_fn = function(agent, input_text) "[FINAL] done"
    #' )
    #' out <- orchestrator$run("hello")
    #' length(out)
    #' @export
    new_multiagent_orchestrator <- function(participants,
                                            termination_fn = final_keyword_termination("[FINAL]"),
                                            max_turns = 6,
                                            step_fn = NULL) {
      stopifnot(is.list(participants), length(participants) >= 1)
      for (p in participants) {
        if (!is.list(p) || is.null(p$role) || is.null(p$agent)) stop("Each participant must be list(role, agent)")
      }
      env <- new.env(parent = emptyenv())
      env$participants <- participants
      env$termination_fn <- termination_fn
      env$max_turns <- as.integer(max_turns)
      env$step_fn <- step_fn %||% function(agent, input_text) agent_reply(agent, input_text, json = TRUE)
      env$messages <- list()

      env$transcript <- function() env$messages

      env$run <- function(initial_user_text) {
        # seed transcript with user message
        env$messages <- list(create_message("user", as.character(initial_user_text)[1]))
        turns <- 0L
        while (turns < env$max_turns) {
          for (i in seq_along(env$participants)) {
            last <- env$messages[[length(env$messages)]]
            input_text <- last$content %||% ""
            p <- env$participants[[i]]
            reply <- env$step_fn(p$agent, input_text)
            reply <- as.character(reply)[1]
            env$messages <- c(env$messages, list(create_message("assistant", reply, name = p$role)))
            turns <- turns + 1L
            if (isTRUE(env$termination_fn(env$messages))) {
              return(env$messages)
            }
            if (turns >= env$max_turns) break
          }
        }
        env$messages
      }

      class(env) <- c("llmr_multiagent_orchestrator", class(env))
      env
    }

    #' Termination policy: stop when keyword appears in last assistant message
    #'
    #' @param keyword Keyword (string) to detect, default "\[FINAL\]".
    #' @return A function suitable for `termination_fn`.
    #' @export
    final_keyword_termination <- function(keyword = "[FINAL]") {
      force(keyword)
      function(messages) {
        if (!length(messages)) return(FALSE)
        last <- messages[[length(messages)]]
        if (!identical(last$role, "assistant")) return(FALSE)
        grepl(keyword, last$content %||% "", fixed = TRUE)
      }
    }

