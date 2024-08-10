#!/bin/bash

# Replace /path/to/directory with the directory you want to iterate over
for file in ./sources/*; do
  # Check if it's a file (and not a directory)
  if [ -f "$file" ]; then
    # Perform an action with the file
    echo "Processing $file"
    chatgpt-md-translator $file

  fi
done