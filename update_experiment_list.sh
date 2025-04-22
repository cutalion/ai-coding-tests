#!/bin/bash

# Create a JSON file of all experiment directories for the main index.html

# Check for required dependencies
check_dependency() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: Required command '$1' not found. Please install it before running this script."
    return 1
  fi
}

# Get the script's directory without using readlink (which might not be available)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results"
OUTPUT_FILE="${RESULTS_DIR}/experiments.json"

# Check if results directory exists
if [ ! -d "$RESULTS_DIR" ]; then
  echo "Results directory not found: $RESULTS_DIR"
  echo "Creating results directory..."
  mkdir -p "$RESULTS_DIR"
  if [ ! -d "$RESULTS_DIR" ]; then
    echo "Error: Failed to create results directory"
    exit 1
  fi
fi

# Generate empty JSON array for experiments
echo "[" > "$OUTPUT_FILE"

# Find all experiment directories using a simpler approach
FIRST=true

# Change to results directory
cd "$RESULTS_DIR" || { echo "Error changing to results directory"; exit 1; }

# Use shell globbing instead of find
for DIR in */; do
  # Remove trailing slash
  DIR_NAME=${DIR%/}
  
  # Skip templates directory if it exists in results
  if [[ "$DIR_NAME" == "templates" ]]; then
    continue
  fi
  
  # Check if the directory contains an index.html file
  if [ -f "${DIR_NAME}/index.html" ]; then
    if [ "$FIRST" = false ]; then
      echo "," >> "$OUTPUT_FILE"
    else
      FIRST=false
    fi
    
    # Add entry to JSON
    echo "  {" >> "$OUTPUT_FILE"
    echo "    \"id\": \"${DIR_NAME}\"," >> "$OUTPUT_FILE"
    echo "    \"path\": \"${DIR_NAME}/index.html\"" >> "$OUTPUT_FILE"
    echo "  }" >> "$OUTPUT_FILE"
  fi
done

# Change back to original directory
cd "$SCRIPT_DIR" || { echo "Error changing back to script directory"; exit 1; }

# Close the JSON array
echo "]" >> "$OUTPUT_FILE"

echo "Experiment list updated at $OUTPUT_FILE"