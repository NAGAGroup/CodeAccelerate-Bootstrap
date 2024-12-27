#!/bin/bash

# Check if fonts directory exists
if [ ! -d "./fonts" ]; then
	echo "Error: ./fonts directory not found"
	exit 1
fi

# Create user fonts directory if it doesn't exist
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

echo "Installing fonts from ./fonts directory..."

# Copy all font files to user fonts directory
find ./fonts -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR/" \;

# Update font cache
fc-cache -f -v

echo "Font installation complete!"
