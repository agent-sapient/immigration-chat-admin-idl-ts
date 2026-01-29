#!/bin/bash

# Script to generate src/index.ts by traversing src directory
# Usage: ./generate-index.sh

SRC_DIR="src"
INDEX_FILE="${SRC_DIR}/index.ts"

# Function to convert .ts path to .js export path
to_export_path() {
    local file="$1"
    # Remove src/ prefix and .ts extension, add .js
    echo "$file" | sed 's|^src/||' | sed 's|\.ts$|.js|'
}

# Start generating the index file
cat > "$INDEX_FILE" << 'EOF'
// Main entry point for the wallet library

EOF

# Find all .ts files in src directory (excluding index.ts itself)
# Sort them for consistent output
# Use a temporary file to avoid sub-shell issues
TMP_FILE=$(mktemp)
find "$SRC_DIR" -name "*.ts" -type f ! -name "index.ts" | sort > "$TMP_FILE"

prev_dir=""
while IFS= read -r file; do
    # Get relative path from src directory
    rel_path=$(echo "$file" | sed 's|^src/||' | sed 's|\.ts$||')
    dir=$(dirname "$rel_path")
    
    # Add directory comment if directory changed
    if [ "$dir" != "$prev_dir" ] && [ "$dir" != "." ]; then
        # Format directory as comment
        comment=$(echo "$dir" | sed 's|/| |g')
        echo "" >> "$INDEX_FILE"
        echo "// $comment" >> "$INDEX_FILE"
    fi
    
    # Generate export statement
    export_path=$(to_export_path "$file")
    echo "export * from \"./$export_path\";" >> "$INDEX_FILE"
    
    # Update previous directory
    prev_dir="$dir"
done < "$TMP_FILE"

# Clean up temporary file
rm "$TMP_FILE"

# Add a newline at the end
echo "" >> "$INDEX_FILE"

echo "Generated $INDEX_FILE successfully!"
