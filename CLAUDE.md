# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Run all tests with mods CLI: `./run_tests.sh`
- Run all tests with direct API calls: `./run_tests_curl.sh`
- Run with custom prompt: `./run_tests.sh -p "your prompt here"` (or `./run_tests_curl.sh -p "your prompt here"`)
- Test specific models: `./run_tests.sh -m gpt-4o,sonnet-3.7` (or `./run_tests_curl.sh -m gpt-4o,sonnet-3.7`)
- Set experiment name: `./run_tests.sh -n experiment-name` (or `./run_tests_curl.sh -n experiment-name`)
- Deploy to Netlify: `./run_tests.sh -d` (or `./run_tests_curl.sh -d`)
- Show help: `./run_tests.sh -h` (or `./run_tests_curl.sh -h`)
- Install dependencies: `npm install`
- Set up API keys: Copy `.env.example` to `.env` and add your keys (for `run_tests_curl.sh`)

## Testing Framework
- Tests generate AI model implementations based on customizable prompts
- Two methods available: mods CLI (`run_tests.sh`) or direct API calls (`run_tests_curl.sh`)
- Results are stored in timestamped directories under `results/`
- Each test run creates HTML outputs for each model tested
- Default settings are stored in `defaults.sh`
- API keys for direct calls should be stored in `.env` (see `.env.example`)
- Main index at results/index.html shows all experiments

## Coding Guidelines
- HTML/JS/CSS should be clean, self-contained, and ready to run
- Avoid markdown formatting in generated code
- Follow standard web development best practices
- Ensure generated code is properly formatted and indented
- When modifying shell scripts, follow POSIX-compatible syntax
- Use meaningful variable names and add comments where appropriate