# AI Coding Tests

A framework for testing and comparing code generation capabilities across various AI models.

## Overview

This tool allows you to:

- Send the same coding prompt to multiple AI models simultaneously
- Generate HTML/JS/CSS implementations from each model
- Compare the results side-by-side
- Deploy the results to Netlify for easy sharing and viewing

## Requirements

- Node.js
- NPM
- One of the following:
  - [Mods CLI](https://github.com/charmbracelet/mods) for the default script (`mods` command must be available)
  - API keys for various models if using the direct API method (see `.env.example`)
- Netlify account (optional, for deployment)

## Installation

1. Clone this repository
2. Install dependencies:
   ```
   npm install
   ```

## Usage

### Basic Usage

Run the test script with default settings using either:

```bash
# Using mods CLI
./run_tests.sh

# Using direct API calls
./run_tests_curl.sh
```

Both scripts will:
1. Query all configured AI models with the default tic-tac-toe prompt
2. Generate HTML/JS/CSS implementations for each model
3. Create a timestamped results directory with all outputs
4. Generate an index.html file to compare results

**Note for API version**: If using the direct API version (`run_tests_curl.sh`), you need to set up the API keys:
1. Copy `.env.example` to `.env`
2. Add your API keys to the `.env` file

### Custom Usage

You can customize the tests with various options:

```
Usage: ./run_tests.sh [OPTIONS]

Options:
  -h, --help                 Show this help message
  -p, --prompt TEXT          Custom prompt (default: tic-tac-toe game prompt)
  -m, --models MODEL1,MODEL2 Comma-separated list of models to test
  -n, --name NAME            Experiment name prefix (default: ai-test)
  -d, --deploy               Deploy results to Netlify after completion

Examples:
  ./run_tests.sh                                     # Run with default settings
  ./run_tests.sh -p "write a calculator in HTML/JS"  # Custom prompt
  ./run_tests.sh -m gpt-4o,sonnet-3.7                # Test specific models
  ./run_tests.sh -n calculator-test                  # Custom experiment name
  ./run_tests.sh -d                                  # Deploy results to Netlify
```

### Viewing Results

After running tests, you'll find the results in:
```
results/[experiment_name]_[timestamp]/
```

Open the `index.html` file in this directory to compare model outputs.

You can also browse all experiments by opening `results/index.html`.

### Deployment

To deploy your results to Netlify:

```
./run_tests.sh -d
```

Or deploy existing results:

```
npm run deploy
```

## Customizing Defaults

Edit `defaults.sh` to change the default:
- Models to test
- Prompt to use
- Experiment name prefix

## Structure

- `run_tests.sh` - Main script to run tests using mods CLI
- `run_tests_curl.sh` - Alternative script using direct API calls with curl
- `defaults.sh` - Default configuration settings
- `update_experiment_list.sh` - Updates list of experiments for the dashboard
- `templates/` - HTML templates for result pages
- `results/` - Contains all test results (excluded from git)
- `.env.example` - Example environment variables for API keys

## Sharing on GitHub

This project is set up to exclude test results from git. When you push to GitHub:

1. All code and templates will be included
2. All test results in the `results/` directory will be excluded
3. Others who clone your repository can run their own tests and generate their own results

## License

MIT