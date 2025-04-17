#!/bin/bash

# Load defaults
source "$(dirname "$0")/defaults.sh"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -h, --help                 Show this help message"
  echo "  -p, --prompt TEXT          Custom prompt (default: tic-tac-toe game prompt)"
  echo "  -m, --models MODEL1,MODEL2 Comma-separated list of models to test"
  echo "  -n, --name NAME            Experiment name prefix (default: ai-test)"
  echo "  -d, --deploy               Deploy results to Netlify after completion"
  echo
  echo "Examples:"
  echo "  $0                                              # Run with default settings"
  echo "  $0 -p \"write a calculator in HTML/JS\"          # Custom prompt"
  echo "  $0 -m gpt-4o,sonnet-3.7                        # Test specific models"
  echo "  $0 -n calculator-test                          # Custom experiment name"
  echo "  $0 -d                                          # Deploy results to Netlify"
}

# Parse command line arguments
PROMPT="$DEFAULT_PROMPT"
MODELS=("${DEFAULT_MODELS[@]}")
EXPERIMENT_NAME="$DEFAULT_EXPERIMENT_NAME"
DEPLOY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -p|--prompt)
      PROMPT="$2"
      shift 2
      ;;
    -m|--models)
      IFS=',' read -r -a MODELS <<< "$2"
      shift 2
      ;;
    -n|--name)
      EXPERIMENT_NAME="$2"
      shift 2
      ;;
    -d|--deploy)
      DEPLOY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Ensure prompt has the needed formatting instructions
if ! [[ "$PROMPT" =~ "NO MARKDOWN" ]]; then
  PROMPT="${PROMPT}. Return just the code which is ready to run as is. DO NOT WRAP RESPONSE AND CODE in backticks, NO MARKDOWN, no explanations, use plain text only."
fi

# Create experiment ID with name prefix and timestamp
TIMESTAMP=$(date +"%d.%m.%Y_%T")
EXPERIMENT_ID="${EXPERIMENT_NAME}_${TIMESTAMP}"
EXPERIMENT_RESULTS_DIR="results/$EXPERIMENT_ID"

mkdir -p "$EXPERIMENT_RESULTS_DIR"

echo "Starting experiment: $EXPERIMENT_ID"
echo "Testing with prompt: $PROMPT"
echo "Using models: ${MODELS[*]}"

# Save the experiment configuration
cat > "${EXPERIMENT_RESULTS_DIR}/config.txt" << EOF
Experiment: ${EXPERIMENT_ID}
Prompt: ${PROMPT}
Models: ${MODELS[*]}
EOF

# Iterate through each model and generate HTML code
for model in "${MODELS[@]}"; do
  echo "Generating using $model..."
  mods -r -f text -m "$model" "$PROMPT" > "${EXPERIMENT_RESULTS_DIR}/${model}.html"
done

# Generate index.html with links to all model files
echo "Generating index.html..."
cat > "${EXPERIMENT_RESULTS_DIR}/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${EXPERIMENT_NAME} - ${TIMESTAMP}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            color: #333;
        }
        .prompt {
            background-color: #f8f8f8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #0066cc;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 10px 0;
            padding: 10px;
            border-radius: 5px;
            background-color: #f5f5f5;
        }
        a {
            display: block;
            color: #0066cc;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
        .back-link {
            margin-top: 30px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <h1>${EXPERIMENT_NAME} Results</h1>
    <p>Experiment ID: ${EXPERIMENT_ID}</p>
    
    <div class="prompt">
        <h3>Prompt:</h3>
        <p>${PROMPT}</p>
    </div>
    
    <ul>
EOF

# Add links for each model
for model in "${MODELS[@]}"; do
  echo "        <li><a href=\"${model}.html\" target=\"_blank\">${model}</a></li>" >> "${EXPERIMENT_RESULTS_DIR}/index.html"
done

# Add a back link to the main index
cat >> "${EXPERIMENT_RESULTS_DIR}/index.html" << EOF
    </ul>
    
    <a href="../index.html" class="back-link">← Back to all experiments</a>
</body>
</html>
EOF

# Update the experiment list for the main index
./update_experiment_list.sh

echo "Generation complete."
echo "Check $EXPERIMENT_RESULTS_DIR for results"
echo "Open $EXPERIMENT_RESULTS_DIR/index.html to view all models"

# Deploy to Netlify if requested
if [ "$DEPLOY" = true ]; then
  echo "Deploying to Netlify..."
  npx netlify deploy --dir=results --prod
fi