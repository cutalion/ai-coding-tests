#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
  echo "Loading environment variables from .env file..."
  source ".env"
fi

echo "Environment Variables Check:"
echo "=================================="

# Function to display API key with first 3 and last 3 characters
display_key() {
  local key=$1
  local name=$2
  local length=${#key}
  
  if [ $length -le 6 ]; then
    echo "$name: Configured ✓ (value: $key)"
  else
    local first_three=${key:0:3}
    local last_three=${key: -3}
    echo "$name: Configured ✓ (${first_three}...${last_three})"
  fi
}

# Check OpenAI API Key
if [ -n "$OPENAI_API_KEY" ]; then
  display_key "$OPENAI_API_KEY" "OPENAI_API_KEY"
else
  echo "OPENAI_API_KEY: Not configured ✗"
fi

# Check Anthropic API Key
if [ -n "$ANTHROPIC_API_KEY" ]; then
  display_key "$ANTHROPIC_API_KEY" "ANTHROPIC_API_KEY"
else
  echo "ANTHROPIC_API_KEY: Not configured ✗"
fi

# Check Gemini API Key
if [ -n "$GEMINI_API_KEY" ]; then
  display_key "$GEMINI_API_KEY" "GEMINI_API_KEY"
else
  echo "GEMINI_API_KEY: Not configured ✗"
fi

# Check Groq API Key
if [ -n "$GROQ_API_KEY" ]; then
  display_key "$GROQ_API_KEY" "GROQ_API_KEY"
else
  echo "GROQ_API_KEY: Not configured ✗"
fi

# Check DeepSeek API Key
if [ -n "$DEEPSEEK_API_KEY" ]; then
  display_key "$DEEPSEEK_API_KEY" "DEEPSEEK_API_KEY"
else
  echo "DEEPSEEK_API_KEY: Not configured ✗"
fi

# Check Yandex Cloud API Key
if [ -n "$YANDEX_CLOUD_API_KEY" ]; then
  display_key "$YANDEX_CLOUD_API_KEY" "YANDEX_CLOUD_API_KEY"
  echo "  Length: ${#YANDEX_CLOUD_API_KEY} characters"
else
  echo "YANDEX_CLOUD_API_KEY: Not configured ✗"
fi

# Check Yandex Folder ID
if [ -n "$YANDEX_FOLDER_ID" ]; then
  display_key "$YANDEX_FOLDER_ID" "YANDEX_FOLDER_ID"
else
  echo "YANDEX_FOLDER_ID: Not configured ✗"
fi

echo ""
echo "Environment Configuration Status:"
echo "=================================="

# Create a .env file if it doesn't exist
if [ ! -f ".env" ]; then
  echo "No .env file found. Creating from template..."
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "Created .env file from .env.example template."
    echo "Please edit the .env file and add your API keys."
  else
    echo "No .env.example file found. Please create a .env file manually."
  fi
else
  echo ".env file exists."
fi