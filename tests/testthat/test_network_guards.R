test_that("network tools hard-fail when disabled", {
  clear_tools()
  register_basic_tools(enable_network = FALSE)
  expect_error(call_tool("web_search", list(q = "r project")), "Network-disabled")
  expect_error(call_tool("wiki_fetch", list(title = "R_(programming_language)")), "Network-disabled")
})

