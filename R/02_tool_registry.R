    
    #' Tool and Tool Registry
    #'
    #' Tools are conservative, explicit functions an agent may invoke.
    #' They validate inputs and return a character result.
    #'
    #' @section Registry design:
    #' - Global, in-memory registry stored under option `LLMRAgent.tools`.
    #' - Idempotent add/remove by unique `name`.
    #' - Thread-safe for base-R single-threaded code. No promises under forked parallelism.
    #'
    #' @seealso [register_basic_tools()], [register_tool()], [unregister_tool()], [list_tools()], [get_tool()], [call_tool()]
    #' @name tool-api
    NULL

    #' Create a Tool
    #'
    #' @param name Unique tool name (snake_case).
    #' @param description One-line description for the LLM.
    #' @param parameters Named list describing expected fields (JSON-like).
    #' @param fun Function taking a single list `args` and returning character.
    #' @return A tool object.
    #' @examples
    #' add_one <- make_tool(
    #'   name = "add_one",
    #'   description = "Add one to x",
    #'   parameters = list(x = list(type = "number", required = TRUE)),
    #'   fun = function(args) as.character(args$x + 1)
    #' )
    #' @export
    make_tool <- function(name, description, parameters, fun) {
      stopifnot(is.character(name), length(name) == 1)
      stopifnot(is.character(description), length(description) == 1)
      stopifnot(is.list(parameters), is.function(fun))
      structure(
        list(
          name = name,
          description = description,
          parameters = parameters,
          fun = fun
        ),
        class = "llmr_tool"
      )
    }

    #' @keywords internal
    #' @noRd
    .validate_and_coerce_args <- function(parameters, args) {
      # extremely conservative: ensure only declared fields and required present
      if (!is.list(args)) stop("Tool args must be a list.")
      declared <- names(parameters)
      missing_req <- names(Filter(function(x) isTRUE(x$required), parameters))
      missing_req <- setdiff(missing_req, names(args))
      if (length(missing_req)) stop("Missing required args: ", paste(missing_req, collapse = ", "))
      extra <- setdiff(names(args), declared)
      if (length(extra)) stop("Unexpected args: ", paste(extra, collapse = ", "))

      # Coerce simple types and enforce simple constraints if provided
      out <- args
      for (nm in declared) {
        spec <- parameters[[nm]]
        if (is.null(out[[nm]])) next
        val <- out[[nm]]
        ptype <- spec$type %||% NULL

        # type coercion
        if (identical(ptype, "number")) {
          val2 <- suppressWarnings(as.numeric(val))
          if (is.na(val2)) stop(sprintf("Argument '%s' must be a number.", nm))
          val <- val2
        } else if (identical(ptype, "boolean")) {
          if (is.logical(val)) {
            val <- as.logical(val)
          } else if (is.character(val)) {
            v <- tolower(trimws(val))
            if (v %in% c("true","t","1","yes")) val <- TRUE
            else if (v %in% c("false","f","0","no")) val <- FALSE
            else stop(sprintf("Argument '%s' must be boolean.", nm))
          } else if (is.numeric(val)) {
            val <- as.numeric(val) != 0
          } else {
            stop(sprintf("Argument '%s' must be boolean.", nm))
          }
        } else if (identical(ptype, "string")) {
          val <- as.character(val)[1]
        }

        # constraints
        if (!is.null(spec$enum)) {
          if (!(val %in% spec$enum)) {
            stop(sprintf("Argument '%s' must be one of: %s", nm, paste(spec$enum, collapse = ", ")))
          }
        }
        if (!is.null(spec$min) || !is.null(spec$max)) {
          if (!is.numeric(val)) stop(sprintf("Argument '%s' must be numeric for range checks.", nm))
          if (!is.null(spec$min) && val < spec$min) stop(sprintf("Argument '%s' must be >= %s", nm, spec$min))
          if (!is.null(spec$max) && val > spec$max) stop(sprintf("Argument '%s' must be <= %s", nm, spec$max))
        }

        out[[nm]] <- val
      }
      out
    }

    #' Execute a Tool (internal)
    #' @param tool a `llmr_tool`
    #' @param args list of arguments
    #' @return character
    #' @keywords internal
    #' @noRd
    .run_tool <- function(tool, args) {
      args2 <- .validate_and_coerce_args(tool$parameters, args)
      out <- tool$fun(args2)
      stopifnot(is.character(out), length(out) == 1L)
      out
    }

    #' Register a tool globally
    #' @param tool A `llmr_tool`.
    #' @seealso [unregister_tool()], [list_tools()], [get_tool()], [tool-api]
    #' @export
    register_tool <- function(tool) {
      stopifnot(inherits(tool, "llmr_tool"))
      reg <- getOption("LLMRAgent.tools", list())
      if (tool$name %in% names(reg)) stop("Tool already registered: ", tool$name)
      reg[[tool$name]] <- tool
      options(LLMRAgent.tools = reg)
      invisible(tool$name)
    }

    #' Unregister a tool globally
    #'
    #' Removes a tool by `name`. No-op if not present.
    #'
    #' @param name Tool name to remove.
    #' @return Logical indicating whether a tool was removed.
    #' @seealso [register_tool()], [list_tools()], [tool-api]
    #' @export
    unregister_tool <- function(name) {
      reg <- getOption("LLMRAgent.tools", list())
      if (!length(reg) || is.null(reg[[name]])) return(FALSE)
      reg[[name]] <- NULL
      options(LLMRAgent.tools = reg)
      TRUE
    }

    #' Get a tool by name
    #' @param name tool name
    #' @seealso [register_tool()], [unregister_tool()], [list_tools()]
    #' @export
    get_tool <- function(name) {
      reg <- getOption("LLMRAgent.tools", list())
      reg[[name]]
    }

    #' List all registered tools
    #' @return tibble with tool names and descriptions
    #' @seealso [register_tool()], [unregister_tool()], [get_tool()]
    #' @export
    list_tools <- function() {
      reg <- getOption("LLMRAgent.tools", list())
      if (!length(reg)) return(tibble::tibble(name = character(), description = character()))
      tibble::tibble(
        name = names(reg),
        description = vapply(reg, `[[`, "", "description"),
        stringsAsFactors = FALSE
      )
    }

    #' Clear all registered tools
    #' @seealso [list_tools()], [register_tool()], [unregister_tool()], [get_tool()]
    #' @export
    clear_tools <- function() {
      options(LLMRAgent.tools = list())
      invisible(TRUE)
    }

    #' Call a registered tool by name (manual invocation)
    #'
    #' This is provided so that, even without any LLM integration,
    #' developers can reliably execute tools from R code.
    #'
    #' @param name Registered tool name.
    #' @param args Named list of arguments.
    #' @return Character result returned by the tool.
    #' @examples
    #' \dontrun{
    #' register_tool(make_tool("hello", "say hello", list(), function(args) "hi"))
    #' call_tool("hello", list())
    #' }
    #' @export
    call_tool <- function(name, args = list()) {
      tool <- get_tool(name)
      if (is.null(tool)) stop("Tool not found: ", name)
      .run_tool(tool, args)
    }
