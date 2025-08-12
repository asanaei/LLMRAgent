# LLMRAgent

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/asanaei/LLMRAgent/workflows/R-CMD-check/badge.svg)](https://github.com/asanaei/LLMRAgent/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CRAN status](https://www.r-pkg.org/badges/version/LLMRAgent)](https://CRAN.R-project.org/package=LLMRAgent)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/LLMRAgent)](https://CRAN.R-project.org/package=LLMRAgent)
[![GitHub issues](https://img.shields.io/github/issues/asanaei/LLMRAgent)](https://github.com/asanaei/LLMRAgent/issues)
<!-- badges: end -->

> **Simple agent framework for R that integrates directly with LLMR package**

LLMRAgent provides a clean, simple interface for creating AI agents using LLMR model configurations. No complex adapters, just direct integration with `LLMR::llm_config()` and `call_llm_robust()`.

## Key Features

- **Direct LLMR Integration**: Uses `LLMR::llm_config()` directly 
- **Made to be intuitive to use**

## Installation

### From CRAN (When available)

```r
install.packages("LLMRAgent")
```

### From GitHub (Current)

```r
# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install LLMRAgent
devtools::install_github("asanaei/LLMRAgent")
```

## Prerequisites

You need the [LLMR package](https://github.com/asanaei/LLMR) and valid API credentials:

```r
install.packages("LLMR")  # Or devtools::install_github("asanaei/LLMR")
```

## Quick Start

```r
library(LLMR)
library(LLMRAgent)

# Create LLMR model configuration
config <- LLMR::llm_config(
  provider = "openai",
  model = "gpt-4o-mini",
  api_key = Sys.getenv("OPENAI_API_KEY")
)

# Create agent
agent <- new_agent(
  system_prompt = "You are a helpful R programming assistant.",
  model_config = config
)

# Chat with the agent
reply <- agent_reply(agent, "What is R?")
cat(reply)
```

## JSON Mode

Enable structured responses with JSON mode:

```r
# JSON mode (default)
json_reply <- agent_reply(
  agent, 
  "List 3 benefits of R as JSON with keys: benefit1, benefit2, benefit3",
  json = TRUE
)

# Parse the response
parsed <- jsonlite::fromJSON(json_reply)
print(parsed)
```

## Token Usage Tracking

Agents automatically track token usage across all interactions:

```r
# Usage is tracked automatically with each call
agent_reply(agent, "What is R?")
agent_reply(agent, "What is Python?") 
agent_reply(agent, "Compare them")

# Check cumulative usage at any time
usage <- agent_usage(agent)
cat("Total tokens:", usage$total_tokens)
cat("Interactions:", usage$interactions)

# Reset usage tracking if needed
agent_usage_reset(agent)
```

## Memory Management

Agents automatically manage conversation history:

```r
# Create agent with custom memory size
agent <- new_agent(
  system_prompt = "Remember our conversation.",
  model_config = config,
  memory = new_buffer_memory(10)  # Keep last 10 messages
)

# Multi-turn conversation
agent_reply(agent, "My name is Alice")
agent_reply(agent, "What's my name?")  # Agent remembers!
```

## Examples

See the `inst/examples/` directory for complete examples:

- **Basic Usage**: Simple agent interactions
- **JSON Mode**: Structured response handling  
- **Memory**: Multi-turn conversations
- **Multiple Providers**: OpenAI, Anthropic, etc.

## API Reference

### Core Functions

- `new_agent(system_prompt, model_config, memory)` - Create new agent
- `agent_reply(agent, user_text, json)` - Get agent response
- `agent_usage(agent)` - Get cumulative token usage
- `agent_usage_reset(agent)` - Reset usage tracking
- `new_buffer_memory(size)` - Create conversation memory

### Requirements

- **model_config**: Required LLMR configuration from `LLMR::llm_config()`
- **API Keys**: Valid credentials for your chosen provider

## Supported Providers

Through LLMR integration:

- **OpenAI**: GPT-4, GPT-4o, GPT-3.5-turbo
- **Anthropic**: Claude-3, Claude-3.5
- **Google**: Gemini models
- **Ollama**: Local models
- **Azure OpenAI**: Enterprise deployments

## Error Handling

The package enforces proper usage:

```r
# This fails - config is required
new_agent("Be helpful.")
#> Error: model_config is required. Use LLMR::llm_config() to create one.
```

## Documentation

- **Vignette**: `vignette("quickstart", package = "LLMRAgent")`
- **Examples**: `system.file("examples", package = "LLMRAgent")`
- **Help**: `?new_agent`, `?agent_reply`

## Related Packages

- **[LLMR](https://github.com/asanaei/LLMR)**: Core LLM interface (required)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

```r
citation("LLMRAgent")
```

## Issues

Found a bug or have a suggestion? Please [open an issue](https://github.com/asanaei/LLMRAgent/issues).
<<<<<<< HEAD

---

**Made with ❤️ for the R community**
=======
>>>>>>> fa48ca8 (readme update)
