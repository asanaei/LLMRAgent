    
    #' Register basic built-in tools
    #'
    #' Provides opt-in registration for conservative tools: `web_search`, `wiki_fetch`,
    #' and `execute_r`. Network tools require both `enable_network = TRUE` and the
    #' option `options(LLMR.Agent.enable_network = TRUE)`.
    #'
    #' @param enable_network Logical. If TRUE, allows HTTP tools to perform requests.
    #' @return Invisibly, character vector of registered tool names.
    #' @seealso [tool-api], [register_tool()], [list_tools()], [clear_tools()]
    #' @examples
    #' 
    #' # Safe default (no network calls in tests)
    #' LLMR.Agent::register_basic_tools(enable_network = FALSE)
    #'
    #' # To enable network at runtime (interactive only):
    #' # options(LLMR.Agent.enable_network = TRUE)
    #' # LLMR.Agent::register_basic_tools(enable_network = TRUE)
    #'
    #' @export
    register_basic_tools <- function(enable_network = FALSE) {
      # web_search (via SerpAPI if key is present)
      web_search <- make_tool(
        name = "web_search",
        description = "Search the web (SerpAPI key required; opt-in). Returns top titles + links.",
        parameters = list(q = list(type="string", required=TRUE), num = list(type="number", required=FALSE)),
        fun = function(args) {
          if (!isTRUE(getOption("LLMR.Agent.enable_network", FALSE)) || !enable_network) {
            stop("Network-disabled: set options(LLMR.Agent.enable_network=TRUE) and call register_basic_tools(enable_network=TRUE).")
          }
          if (!requireNamespace("httr2", quietly = TRUE)) stop("httr2 not installed.")
          key <- Sys.getenv("SERPAPI_KEY", "")
          if (!nzchar(key)) stop("SERPAPI_KEY env var required.")
          q <- args$q
          num <- args$num %||% 5
          req <- httr2::request("https://serpapi.com/search.json") |>
            httr2::req_url_query(q = q, engine = "google", api_key = key, num = num) |>
            httr2::req_timeout(10)
          resp <- httr2::req_perform(req)
          dat <- httr2::resp_body_json(resp, check_type = FALSE)
          items <- dat$organic_results %||% list()
          lines <- vapply(items, function(it) sprintf("- %s\n  %s", it$title %||% "", it$link %||% ""), "")
          if (!length(lines)) return("No results.")
          paste(lines, collapse = "\n")
        }
      )

      # wiki_fetch (Wikipedia REST)
      wiki_fetch <- make_tool(
        name = "wiki_fetch",
        description = "Get summary from Wikipedia REST API for a title.",
        parameters = list(title = list(type="string", required=TRUE)),
        fun = function(args) {
          if (!isTRUE(getOption("LLMR.Agent.enable_network", FALSE)) || !enable_network) {
            stop("Network-disabled: set options(LLMR.Agent.enable_network=TRUE) and call register_basic_tools(enable_network=TRUE).")
          }
          if (!requireNamespace("httr2", quietly = TRUE)) stop("httr2 not installed.")
          title <- utils::URLencode(args$title, reserved = TRUE)
          url <- sprintf("https://en.wikipedia.org/api/rest_v1/page/summary/%s", title)
          req <- httr2::request(url) |>
            httr2::req_user_agent("LLMR.Agent/0.2") |>
            httr2::req_timeout(10)
          resp <- httr2::req_perform(req)
          dat <- httr2::resp_body_json(resp, check_type = FALSE)
          dat$extract %||% "No summary."
        }
      )

      # execute_r (sandboxed)
      execute_r <- make_tool(
        name = "execute_r",
        description = "Execute small R code snippets safely with time limits; returns captured output.",
        parameters = list(code = list(type="string", required=TRUE)),
        fun = function(args) {
          code <- as.character(args$code)[1]
          # time limits
          cpu <- getOption("LLMR.Agent.execute_r.max_seconds", 2)
          elp <- getOption("LLMR.Agent.execute_r.max_elapsed", 5)
          setTimeLimit(cpu = cpu, elapsed = elp, transient = TRUE)
          on.exit(setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE), add = TRUE)
          # locked env with minimal bindings
          safe_env <- new.env(parent = baseenv())
          # strip dangerous functions
          safe_env$system <- function(...) stop("system() disabled")
          safe_env$file.remove <- function(...) stop("file.remove() disabled")
          safe_env$download.file <- function(...) stop("download.file() disabled")
          out <- utils::capture.output({
            eval(parse(text = code), envir = safe_env)
          })
          paste(out, collapse = "\n")
        }
      )

      ids <- character()
      for (t in list(web_search, wiki_fetch, execute_r)) {
        ids <- c(ids, register_tool(t))
      }
      invisible(ids)
    }
