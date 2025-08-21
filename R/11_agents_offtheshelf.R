
    #' Create a summarizer-focused agent
    #'
    #' Convenience factory for an agent configured to summarize text/conversations.
    #' It sets a concise summarizer system prompt and wires a summary memory
    #' using the provided `summarizer_model_config` (or falls back to `model_config`).
    #'
    #' @param model_config LLMR model config used as default for chat and fallback
    #' summarization.
    #' @param summarizer_model_config Optional LLMR model config used specifically
    #' for summarization.
    #' @param system_prompt System prompt for summarization.
    #' @param memory Optional memory; defaults to `new_summary_memory()`.
    #' @return An agent environment suitable for summarization tasks.
    #' @examplesIf nzchar(Sys.getenv("OPENAI_API_KEY")) && identical(Sys.getenv("LLMRAgent_RUN_EXAMPLES"), "true")
    #'   cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini",
    #'   api_key = Sys.getenv("OPENAI_API_KEY"))
    #'   ag <- new_summarizer_agent(model_config = cfg)
    #' @export
    new_summarizer_agent <- function(model_config,
                                     summarizer_model_config = NULL,
                                     system_prompt = "You are a concise, faithful summarizer.",
                                     memory = new_summary_memory()) {
      new_agent(
        system_prompt = system_prompt,
        model_config = model_config,
        memory = memory,
        summarizer_model_config = summarizer_model_config %||% model_config
      )
    }

    #' Create a context-based QA agent (no retrieval)
    #'
    #' Factory for a conservative QA agent that answers strictly from provided
    #' context snippets supplied by the caller. No retrieval, no tools.
    #'
    #' @param model_config LLMR model config.
    #' @param system_prompt Optional system prompt used for QA. If NULL, a concise
    #'   default is used that instructs answering strictly from provided snippets,
    #'   citing as \[S#\], and saying 'Insufficient information.' when needed.
    #' @param memory Optional memory; defaults to small buffer.
    #' @return An agent environment.
    #' @examplesIf nzchar(Sys.getenv("OPENAI_API_KEY")) && identical(Sys.getenv("LLMRAgent_RUN_EXAMPLES"), "true")
    #'   if (requireNamespace("LLMR", quietly = TRUE)) {
    #'     cfg <- LLMR::llm_config(
    #'       provider = "openai",
    #'       model = "gpt-4o-mini",
    #'       api_key = Sys.getenv("OPENAI_API_KEY")
    #'     )
    #'     qa <- new_contextqa_agent(model_config = cfg)
    #'     msg <- build_context_message("What is X?", c("Snippet one.", "Snippet two."))
    #'     # agent_reply(qa, msg)
    #'   }
    #' @export
    new_contextqa_agent <- function(model_config,
                                    system_prompt = NULL,
                                    memory = new_buffer_memory(6)) {
      sys <- system_prompt
      if (is.null(sys)) {
        sys <- paste(
          "You are a careful social science research assistant.",
          "Use only the provided context snippets.",
          "Cite snippets as [S#].",
          "If insufficient, say 'Insufficient information.'.",
          "Be concise."
        )
      }
      new_agent(
        system_prompt = sys,
        model_config = model_config,
        memory = memory
      )
    }

    #' Create a text classification agent
    #'
    #' Factory for a classifier agent that outputs a JSON object with keys 'label' and
    #' 'confidence' (0..1).
    #'
    #' @param model_config LLMR model config.
    #' @param labels Character vector of allowed labels (length >= 2).
    #' @param system_prompt Optional system prompt; if NULL a short default is used.
    #' @param memory Optional memory; defaults to small buffer.
    #' @return An agent environment.
    #'
    #' @examplesIf nzchar(Sys.getenv("OPENAI_API_KEY")) && identical(Sys.getenv("LLMRAgent_RUN_EXAMPLES"), "true")
    #'   if (requireNamespace("LLMR", quietly = TRUE)) {
    #'     cfg <- LLMR::llm_config(
    #'       provider = "openai",
    #'       model = "gpt-4o-mini",
    #'       api_key = Sys.getenv("OPENAI_API_KEY")
    #'     )
    #'     clf <- new_classifier_agent(cfg, labels = c("positive","negative"))
    #'     umsg <- build_classification_prompt("Great movie!", c("positive","negative"))
    #'     # json <- agent_reply(clf, umsg, json = TRUE)
    #'   }
    new_classifier_agent <- function(model_config,
                                     labels,
                                     system_prompt = NULL,
                                     memory = new_buffer_memory(4)) {
      stopifnot(is.character(labels), length(labels) >= 2)
      base_sys <- system_prompt %||% "Classify the input into one allowed label and return JSON {label, confidence}."
      lab_line <- paste0("Allowed labels: ", paste(sprintf("'%s'", labels), collapse = ", "), ".")
      sys <- paste(base_sys, lab_line)
      new_agent(
        system_prompt = sys,
        model_config = model_config,
        memory = memory
      )
    }
