#!/bin/bash

# Load defaults
source "$(dirname "$0")/defaults.sh"

# Load environment variables from .env file if it exists
if [ -f "$(dirname "$0")/.env" ]; then
  echo "Loading API keys from .env file..."
  source "$(dirname "$0")/.env"
fi

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
  echo "  -v, --verbose              Enable verbose debugging output"
  echo
  echo "Examples:"
  echo "  $0                                              # Run with default settings"
  echo "  $0 -p \"write a calculator in HTML/JS\"          # Custom prompt"
  echo "  $0 -m gpt-4o,sonnet-3.7                        # Test specific models"
  echo "  $0 -n calculator-test                          # Custom experiment name"
  echo "  $0 -d                                          # Deploy results to Netlify"
  echo "  $0 -v                                          # Run with verbose debugging"
}

# Parse command line arguments
PROMPT="$DEFAULT_PROMPT"
MODELS=("${DEFAULT_MODELS[@]}")
EXPERIMENT_NAME="$DEFAULT_EXPERIMENT_NAME"
DEPLOY=false
VERBOSE=false

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
    -v|--verbose)
      VERBOSE=true
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

# Create results directory (and parent if needed)
mkdir -p "results"
if [ ! -d "results" ]; then
  echo "Error: Failed to create results directory"
  exit 1
fi

# Create experiment results directory
mkdir -p "$EXPERIMENT_RESULTS_DIR"
if [ ! -d "$EXPERIMENT_RESULTS_DIR" ]; then
  echo "Error: Failed to create experiment results directory: $EXPERIMENT_RESULTS_DIR"
  exit 1
fi

# Create results/index.html if it doesn't exist
if [ ! -f "results/index.html" ]; then
  echo "Creating results/index.html from template..."
  cp "templates/index.html" "results/index.html"
fi

echo "Starting experiment: $EXPERIMENT_ID"
echo "Testing with prompt: $PROMPT"
echo "Using models: ${MODELS[*]}"

if [ "$VERBOSE" = true ]; then
  echo "Verbose mode enabled - detailed debugging information will be logged"
  # Create a master debug log for the whole run
  DEBUG_LOG="${EXPERIMENT_RESULTS_DIR}/debug.log"
  echo "====== DEBUG LOG FOR EXPERIMENT: $EXPERIMENT_ID ======" > "$DEBUG_LOG"
  echo "Started at: $(date)" >> "$DEBUG_LOG"
  echo "Prompt: $PROMPT" >> "$DEBUG_LOG"
  echo "Models: ${MODELS[*]}" >> "$DEBUG_LOG"
  echo "Environment:" >> "$DEBUG_LOG"
  echo "  Working directory: $(pwd)" >> "$DEBUG_LOG"
  echo "  Script path: $0" >> "$DEBUG_LOG"
  echo "  Bash version: $BASH_VERSION" >> "$DEBUG_LOG"
  echo "====================================================" >> "$DEBUG_LOG"
fi

# Save the experiment configuration
cat > "${EXPERIMENT_RESULTS_DIR}/config.txt" << EOF
Experiment: ${EXPERIMENT_ID}
Prompt: ${PROMPT}
Models: ${MODELS[*]}
EOF

# Function to make API calls for different models
call_api() {
  local model="$1"
  local prompt="$2"
  local output_file="$3"
  
  echo "Generating using $model..."
  
  # Log start of API call if verbose mode is enabled
  if [ "$VERBOSE" = true ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting API call for model: $model" >> "$DEBUG_LOG"
    echo "-------------------------------------------" >> "$DEBUG_LOG"
    MODEL_DEBUG_DIR="${EXPERIMENT_RESULTS_DIR}/debug/$model"
    mkdir -p "$MODEL_DEBUG_DIR"
    
    # Log model-specific info
    echo "API call details:" > "${MODEL_DEBUG_DIR}/api_info.txt"
    echo "Model: $model" >> "${MODEL_DEBUG_DIR}/api_info.txt"
    echo "Time: $(date)" >> "${MODEL_DEBUG_DIR}/api_info.txt"
    echo "Prompt:" >> "${MODEL_DEBUG_DIR}/api_info.txt"
    echo "$prompt" >> "${MODEL_DEBUG_DIR}/api_info.txt"
  fi
  
  case "$model" in
    # OpenAI models
    gpt-4o|gpt-4.1|gpt-4.1-mini|o3|o3-mini|o4-mini)
      if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY environment variable not set"
        return 1
      fi
      
      curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
          \"model\": \"$model\",
          \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
          \"temperature\": 1.0
        }" | jq -r '.choices[0].message.content' > "$output_file"
      ;;
      
    # Anthropic models
    sonnet-3.7|sonnet-3.5|claude-3-7-sonnet-20250219|claude-3-5-sonnet-20241022)
      if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo "Error: ANTHROPIC_API_KEY environment variable not set"
        return 1
      fi
      
      # Map model aliases to actual model names
      local anthropic_model
      case "$model" in
        sonnet-3.7) anthropic_model="claude-3-7-sonnet-20250219" ;;
        sonnet-3.5) anthropic_model="claude-3-5-sonnet-20241022" ;;
        *) anthropic_model="$model" ;;
      esac
      
      curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "{
          \"model\": \"$anthropic_model\",
          \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
          \"temperature\": 1.0,
          \"max_tokens\": 4000
        }" | jq -r '.content[0].text' > "$output_file"
      ;;
      
    # Google/Gemini models
    gemini-1.5-pro|gemini-1.5-flash|gemini-2.0-flash|gemini-2.0-flash-lite|gemini-2.5-pro)
      if [ -z "$GEMINI_API_KEY" ]; then
        echo "Error: GEMINI_API_KEY environment variable not set"
        return 1
      fi
      
      # Map model aliases to actual model names
      local gemini_model
      case "$model" in
        gemini-1.5-pro) gemini_model="gemini-1.5-pro-latest" ;;
        gemini-1.5-flash) gemini_model="gemini-1.5-flash-latest" ;;
        gemini-2.5-pro) gemini_model="gemini-2.5-pro-preview-03-25" ;;
        *) gemini_model="$model" ;;
      esac
      
      curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/$gemini_model:generateContent" \
        -H "Content-Type: application/json" \
        -H "x-goog-api-key: $GEMINI_API_KEY" \
        -d "{
          \"contents\": [{\"parts\": [{\"text\": \"$prompt\"}]}],
          \"generationConfig\": {\"temperature\": 1.0}
        }" | jq -r '.candidates[0].content.parts[0].text' > "$output_file"
      ;;
      
    # Groq models (for llama3.3-70b)
    llama3.3-70b)
      if [ -z "$GROQ_API_KEY" ]; then
        echo "Error: GROQ_API_KEY environment variable not set"
        return 1
      fi
      
      curl -s -X POST "https://api.groq.com/openai/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -d "{
          \"model\": \"llama-3.3-70b-versatile\",
          \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
          \"temperature\": 1.0
        }" | jq -r '.choices[0].message.content' > "$output_file"
      ;;
      
    # DeepSeek models
    ds-chat)
      if [ -z "$DEEPSEEK_API_KEY" ]; then
        echo "Error: DEEPSEEK_API_KEY environment variable not set"
        return 1
      fi
      
      curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
        -d "{
          \"model\": \"deepseek-chat\",
          \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
          \"temperature\": 1.0
        }" | jq -r '.choices[0].message.content' > "$output_file"
      ;;
      
    # Yandex GPT (OpenAI-compatible API)
    ya-gpt)
      if [ -z "$YANDEX_CLOUD_API_KEY" ]; then
        echo "Error: YANDEX_CLOUD_API_KEY environment variable not set"
        return 1
      fi

      if [ -z "$YANDEX_FOLDER_ID" ]; then
        echo "Error: YANDEX_FOLDER_ID environment variable not set"
        return 1
      fi
      
      curl -s -X POST "https://llm.api.cloud.yandex.net/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $YANDEX_CLOUD_API_KEY" \
        -d "{
          \"model\": \"gpt://${YANDEX_FOLDER_ID}/yandexgpt/latest\",
          \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
          \"temperature\": 1.0
        }" | jq -r '.choices[0].message.content' > "$output_file"
      ;;
      
    *)
      echo "Error: Unsupported model $model"
      echo "This model is not yet implemented with direct API calls."
      echo "Please add support for this model or use mods instead." > "$output_file"
      return 1
      ;;
  esac
  
  # Check curl exit status (will execute only for models that don't have custom error handling)
  CURL_STATUS=$?
  if [ $CURL_STATUS -ne 0 ]; then
    echo "API call failed for $model with curl exit code: $CURL_STATUS"
    echo "API Error: Failed to generate content for $model (curl exit code: $CURL_STATUS)" > "$output_file"
    # Create a debug marker file so we know there was an error
    echo "curl exit code: $CURL_STATUS" > "${output_file}.error"
  fi
  
  # Check if the output file is empty (could happen with jq errors)
  if [ ! -s "$output_file" ]; then
    echo "Warning: Empty output generated for $model"
    echo "API Error: Empty response generated. This might be due to a parsing error or empty response from the API." > "$output_file"
    # If we don't already have a debug file, create one
    if [ ! -f "${output_file}.debug" ]; then
      echo "Empty output file detected. No content was extracted from the API response." > "${output_file}.debug"
    fi
  fi
  
  # Log completion of API call if verbose mode is enabled
  if [ "$VERBOSE" = true ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Completed API call for model: $model" >> "$DEBUG_LOG"
    
    # Check for success or failure
    if [ -s "$output_file" ] && ! grep -q "Error:" "$output_file"; then
      echo "Status: SUCCESS - Generated valid output" >> "$DEBUG_LOG"
    else
      echo "Status: FAILURE - Error generating output" >> "$DEBUG_LOG"
      # Copy any error files to the debug directory for this model
      if [ -d "$MODEL_DEBUG_DIR" ]; then
        if [ -f "${output_file}.error" ]; then
          cp "${output_file}.error" "${MODEL_DEBUG_DIR}/error.txt"
        fi
        if [ -f "${output_file}.debug" ]; then
          cp "${output_file}.debug" "${MODEL_DEBUG_DIR}/debug.txt"
        fi
      fi
    fi
    
    echo "-------------------------------------------" >> "$DEBUG_LOG"
  fi
}

# Iterate through each model and generate HTML code
for model in "${MODELS[@]}"; do
  call_api "$model" "$PROMPT" "${EXPERIMENT_RESULTS_DIR}/${model}.html"
done

# Generate index.html for this experiment
echo "Generating index.html for this experiment..."
MODEL_LINKS=""
for model in "${MODELS[@]}"; do
  MODEL_LINKS="${MODEL_LINKS}        <li><a href=\"${model}.html\" target=\"_blank\">${model}</a></li>\n"
done

# Use template for experiment index
cp "templates/experiment-index.html" "${EXPERIMENT_RESULTS_DIR}/index.html"

# Replace placeholders in the template if sed is available
if [ "$HAVE_SED" = true ]; then
  sed -i "s/EXPERIMENT_NAME/${EXPERIMENT_NAME}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
  sed -i "s/TIMESTAMP/${TIMESTAMP}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
  sed -i "s/EXPERIMENT_ID/${EXPERIMENT_ID}/g" "${EXPERIMENT_RESULTS_DIR}/index.html"
  sed -i "s|PROMPT_TEXT|${PROMPT}|g" "${EXPERIMENT_RESULTS_DIR}/index.html"
  sed -i "s|<!-- MODEL_LINKS -->|${MODEL_LINKS}|" "${EXPERIMENT_RESULTS_DIR}/index.html"
else
  # Create a basic index.html file directly
  cat > "${EXPERIMENT_RESULTS_DIR}/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Coding Test: ${EXPERIMENT_NAME}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
    h1, h2 { color: #333; }
    .models { margin-top: 20px; }
    .prompt { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
    a { color: #0066cc; text-decoration: none; }
    a:hover { text-decoration: underline; }
    li { margin-bottom: 8px; }
  </style>
</head>
<body>
  <h1>AI Coding Test: ${EXPERIMENT_NAME}</h1>
  <p><strong>Experiment ID:</strong> ${EXPERIMENT_ID}</p>
  <p><strong>Timestamp:</strong> ${TIMESTAMP}</p>
  
  <h2>Prompt</h2>
  <div class="prompt">
    <p>${PROMPT}</p>
  </div>
  
  <h2>Models Tested</h2>
  <div class="models">
    <ul>
$(for model in "${MODELS[@]}"; do echo "      <li><a href=\"${model}.html\" target=\"_blank\">${model}</a></li>"; done)
    </ul>
  </div>
  
  <p><a href="../index.html">Back to all experiments</a></p>
</body>
</html>
EOF
fi

# Update the experiment list for the main index
./update_experiment_list.sh

echo "Generation complete."
echo "Check $EXPERIMENT_RESULTS_DIR for results"
echo "Open $EXPERIMENT_RESULTS_DIR/index.html to view all models"

# Add summary to debug log if verbose mode was enabled
if [ "$VERBOSE" = true ]; then
  echo "" >> "$DEBUG_LOG"
  echo "====== EXPERIMENT SUMMARY ======" >> "$DEBUG_LOG"
  echo "Completed at: $(date)" >> "$DEBUG_LOG"
  echo "Total models processed: ${#MODELS[@]}" >> "$DEBUG_LOG"
  echo "" >> "$DEBUG_LOG"
  
  # Count successes and failures
  SUCCESS_COUNT=0
  FAILURE_COUNT=0
  for model in "${MODELS[@]}"; do
    MODEL_FILE="${EXPERIMENT_RESULTS_DIR}/${model}.html"
    if [ -s "$MODEL_FILE" ] && ! grep -q "Error:" "$MODEL_FILE"; then
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      FAILURE_COUNT=$((FAILURE_COUNT + 1))
    fi
  done
  
  echo "Successful API calls: $SUCCESS_COUNT" >> "$DEBUG_LOG"
  echo "Failed API calls: $FAILURE_COUNT" >> "$DEBUG_LOG"
  echo "=============================" >> "$DEBUG_LOG"
  
  echo "Debug information saved to $DEBUG_LOG"
  echo "Run with -v option for detailed debug logs"
fi

# Deploy to Netlify if requested
if [ "$DEPLOY" = true ]; then
  echo "Deploying to Netlify..."
  npx netlify deploy --dir=results --prod
fi