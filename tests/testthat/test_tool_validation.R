test_that("tool arg coercion and constraints work", {
  clear_tools()

  t <- make_tool(
    name = "coerce_demo",
    description = "check coercion",
    parameters = list(
      q = list(type = "string", required = TRUE),
      n = list(type = "number", required = FALSE, min = 1, max = 10),
      flag = list(type = "boolean", required = FALSE),
      mode = list(type = "string", required = FALSE, enum = c("a","b"))
    ),
    fun = function(args) {
      paste0(args$q, ":", args$n %||% NA, ":", args$flag %||% NA, ":", args$mode %||% NA)
    }
  )
  register_tool(t)

  # coercion: number and boolean from strings
  out <- call_tool("coerce_demo", list(q = "x", n = "5", flag = "true", mode = "a"))
  expect_match(out, "x:5:TRUE:a")

  # constraints: range and enum violations
  expect_error(call_tool("coerce_demo", list(q = "x", n = 0)), "must be >=")
  expect_error(call_tool("coerce_demo", list(q = "x", mode = "c")), "one of")
})

