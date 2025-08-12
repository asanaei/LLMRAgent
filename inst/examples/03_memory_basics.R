## Memory basics demo (offline)

library(LLMRAgent)

buf <- new_buffer_memory(3)
buf$add(create_message("user", "first"))
buf$add(create_message("assistant", "hi"))
buf$add(create_message("user", "second"))
buf$add(create_message("user", "third"))
cat("Buffer size:", length(buf$get()), "\n")

sm <- new_summary_memory()
sm$add(create_message("user", "alpha"))
sm$add(create_message("assistant", "ok"))
sm$add(create_message("user", "beta"))
summary_text <- tryCatch(sm$summary(), warning = function(w) { message(conditionMessage(w)); sm$summary() })
cat("Summary stub:", summary_text, "\n")

