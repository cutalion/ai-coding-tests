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

# Create results/index.html if it doesn't exist
if [ ! -f "results/index.html" ]; then
  echo "Creating results/index.html from template..."
  cp "templates/index.html" "results/index.html"
fi

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

# Generate index.html from template
echo "Generating index.html for this experiment..."
MODEL_LINKS=""
for model in "${MODELS[@]}"; do
  MODEL_LINKS="${MODEL_LINKS}        <li><a href=\"${model}.html\" target=\"_blank\">${model}</a></li>\n"
done

# Use template for experiment index
cp "templates/experiment-index.html" "${EXPERIMENT_RESULTS_DIR}/index.html"

# Replace placeholders in the template
sed -i "s/EXPERIMENT_NAME/${EXPERIMENT_NAME}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
sed -i "s/TIMESTAMP/${TIMESTAMP}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
sed -i "s/EXPERIMENT_ID/${EXPERIMENT_ID}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
sed -i "s|PROMPT_TEXT|${PROMPT}|g" "${EXPERIMENT_RESULTS_DIR}/index.html"
sed -i "s|<!-- MODEL_LINKS -->|${MODEL_LINKS}|" "${EXPERIMENT_RESULTS_DIR}/index.html"

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