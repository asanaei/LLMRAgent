    
    #' Build a context QA message
    #'
    #' Formats a user message that includes numbered context snippets followed by a question.
    #' @param question Character scalar question.
    #' @param snippets Character vector of context snippets.
    #' @return Character scalar suitable as user content.
    #' @examples
    #' build_context_message("What is X?", c("A is...", "B is..."))
    #' @export
    build_context_message <- function(question, snippets) {
      stopifnot(is.character(question), length(question) == 1)
      if (!length(snippets)) snippets <- character()
      lines <- c("Context:", paste0("[S", seq_along(snippets), "] ", snippets),
                 "", paste0("Question: ", question))
      paste(lines, collapse = "\n")
    }

    #' Build a classification prompt message
    #'
    #' Formats the user message for classification with explicit labels.
    #' @param text Character scalar input text to classify.
    #' @param labels Character vector of allowed labels.
    #' @return Character scalar suitable as user content.
    #' @examples
    #' build_classification_prompt("Great movie!", c("positive","negative"))
    #' @export
    build_classification_prompt <- function(text, labels) {
      stopifnot(is.character(text), length(text) == 1, is.character(labels), length(labels) >= 2)
      lab_line <- paste(sprintf("'%s'", labels), collapse = ", ")
      paste0(
        "Classify the following text into one of: ", lab_line,
        ". Return JSON with keys: label, confidence (0..1).\n\nText: ", text
      )
    }

