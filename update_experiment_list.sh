#!/bin/bash

# Create a JSON file of all experiment directories for the main index.html

# Get the script's directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
RESULTS_DIR="${SCRIPT_DIR}/results"
OUTPUT_FILE="${RESULTS_DIR}/experiments.json"

# Check if results directory exists
if [ ! -d "$RESULTS_DIR" ]; then
  echo "Results directory not found: $RESULTS_DIR"
  exit 1
fi

# Generate empty JSON array for experiments
echo "[" > "$OUTPUT_FILE"

# Find all experiment directories (skip index.html and experiments.json)
FIRST=true
for DIR in $(find "$RESULTS_DIR" -maxdepth 1 -mindepth 1 -type d | sort -r); do
  # Skip templates directory if it exists in results
  if [[ "$(basename "$DIR")" == "templates" ]]; then
    continue
  fi
  
  # Get just the directory name
  DIR_NAME=$(basename "$DIR")
  
  # Check if the directory contains an index.html file
  if [ -f "${DIR}/index.html" ]; then
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

# Close the JSON array
echo "]" >> "$OUTPUT_FILE"

echo "Experiment list updated at $OUTPUT_FILE"