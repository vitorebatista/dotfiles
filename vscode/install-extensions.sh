#!/bin/bash
# Install VS Code extensions from list
# Usage: bash vscode/install-extensions.sh

while read -r ext; do
  code --install-extension "$ext"
done < "$(dirname "$0")/extensions.txt"

echo "Done! All extensions installed."
