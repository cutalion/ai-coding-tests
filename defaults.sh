#!/bin/bash

# Default models to query
DEFAULT_MODELS=(
  "gpt-4o"
  "gpt-4.1"
  "gpt-4.1-mini"
  "llama3.3-70b"
  "ds-chat"
  "sonnet-3.7"
  "sonnet-3.5"
  "gemini-1.5-pro"
  "gemini-1.5-flash"
  "gemini-2.0-flash"
  "gemini-2.0-flash-lite"
  "gemini-2.5-pro"
  "ya-gpt"
)

# Default prompt text for the models
DEFAULT_PROMPT="write a tic-tac-toe game in a single html page. Return just an HTML/JS/CSS code which is ready to run as is. DO NOT WRAP RESPONSE AND CODE in backticks, NO MARKDOWN, use plain text"

# Default experiment name prefix
DEFAULT_EXPERIMENT_NAME="ai-test"