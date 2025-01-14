#!/bin/bash

# Step 1: Check for or create a .gitignore file and add .env and node_modules
echo "Checking for or creating .gitignore file..."
if [ ! -f .gitignore ]; then
    echo ".gitignore file not found. Creating one..."
    touch .gitignore
else
    echo ".gitignore file already exists."
fi

# Add .env and node_modules to .gitignore if not already present
if ! grep -qx ".env" .gitignore; then
    echo ".env" >> .gitignore
    echo "Added .env to .gitignore."
fi

if ! grep -qx "node_modules" .gitignore; then
    echo "node_modules" >> .gitignore
    echo "Added node_modules to .gitignore."
fi

# Step 2: Initialize Git repository with 'main' as the default branch
PROJECT_NAME=$(basename "$PWD")
echo "Initializing a Git repository for project: $PROJECT_NAME"
git init --initial-branch=main
git add .
git commit -m "Initial commit"

# Step 3: Create GitHub repository
echo "Creating GitHub repository..."
gh repo create "$PROJECT_NAME" --source=. --public --remote=origin

# Step 4: Push changes to GitHub
echo "Pushing changes to GitHub..."
git push -u origin main

# Step 5: Cleanup
echo "Cleaning up temporary script..."
rm -- "$0"
ssh "${vps_user}@${vps_ip}" "rm /tmp/initialize-git-repository-temp.sh"
echo "Cleanup complete. You may now close this terminal."
