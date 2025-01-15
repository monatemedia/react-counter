#!/bin/bash

# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

# Copy the selected GitHub Action template to the workflows directory
echo "Creating GitHub Action in .github/workflows..."
cat <<GITHUB_ACTION > .github/workflows/docker-publish.yml
# Template: Docker Publish
# Description: Docker template to publish applications with CI/CD

name: publish
on:
  push:
    branches: ["main"]
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ghcr.io/\${{ github.actor }}/$current_repo:latest
jobs:
  publish:
    name: Publish Docker Image
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Login to GitHub Container Registry
        run: |
          echo \${{ secrets.PAT }} | docker login ghcr.io -u \${{ github.actor }} --password-stdin
      - name: Build and Push Docker Image
        run: |
          docker build . --tag \${{ env.IMAGE_NAME }}
          docker push \${{ env.IMAGE_NAME }}
  deploy:
    needs: publish
    name: Deploy Image
    runs-on: ubuntu-latest
    steps:
      - name: Install SSH Keys
        run: |
          install -m 600 -D /dev/null ~/.ssh/id_rsa
          echo "\${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          ssh-keyscan -H \${{ secrets.SSH_HOST }} > ~/.ssh/known_hosts
      - name: Pull and Deploy Docker Image
        run: ssh \${{ secrets.SSH_USER }}@\${{ secrets.SSH_HOST }} "cd \${{ secrets.WORK_DIR }} && docker compose pull && docker compose up -d"
      - name: Cleanup SSH Keys
        run: rm -rf ~/.ssh
GITHUB_ACTION

echo "GitHub Action template has been copied to .github/workflows."

# Run Git commands to add, commit, and push changes
echo "Adding changes to git..."
git add .

echo "Committing changes..."
git commit -m "feat: ci"

echo "Pushing changes to the remote repository..."
git push

# Provide the link to the GitHub Actions page for tracking progress
echo "You can track the progress of this action at the following link:"
echo "https://github.com/edward/actions"

# Clean up
echo "Cleaning up temporary script..."
rm -- "$0"
echo "Cleanup complete. You may now close this terminal."
