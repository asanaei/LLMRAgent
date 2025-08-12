    test_that("tool registry basic ops", {
      clear_tools()
      t <- make_tool("hello","say hi", list(), function(args) "hi")
      register_tool(t)
      expect_equal(list_tools()$name, "hello")
      expect_equal(call_tool("hello"), "hi")
      expect_true(unregister_tool("hello"))
      expect_equal(nrow(list_tools()), 0)
    })
