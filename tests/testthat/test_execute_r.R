test_that("execute_r sandbox allows simple expressions", {
  clear_tools()
  register_basic_tools(enable_network = FALSE)
  out <- call_tool("execute_r", list(code = "1+1"))
  expect_true(grepl("2", out))
})

test_that("execute_r blocks dangerous functions", {
  clear_tools()
  register_basic_tools(enable_network = FALSE)
  expect_error(call_tool("execute_r", list(code = "system('ls')")), "disabled")
  expect_error(call_tool("execute_r", list(code = "file.remove('x')")), "disabled")
  expect_error(call_tool("execute_r", list(code = "download.file('http://x','y')")), "disabled")
})

