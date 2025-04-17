# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Run all tests with defaults: `./run_tests.sh`
- Run with custom prompt: `./run_tests.sh -p "your prompt here"`
- Test specific models: `./run_tests.sh -m gpt-4o,sonnet-3.7` 
- Set experiment name: `./run_tests.sh -n experiment-name`
- Deploy to Netlify: `./run_tests.sh -d`
- Show help: `./run_tests.sh -h`
- Install dependencies: `npm install`

## Testing Framework
- Tests generate AI model implementations based on customizable prompts
- Results are stored in timestamped directories under `results/`
- Each test run creates HTML outputs for each model tested
- Default settings are stored in `defaults.sh`
- Main index at results/index.html shows all experiments

## Coding Guidelines
- HTML/JS/CSS should be clean, self-contained, and ready to run
- Avoid markdown formatting in generated code
- Follow standard web development best practices
- Ensure generated code is properly formatted and indented
- When modifying shell scripts, follow POSIX-compatible syntax
- Use meaningful variable names and add comments where appropriate