#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting deployment process..."

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Error: Please switch to main branch before deploying"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them before deploying"
    exit 1
fi

echo "🧹 Cleaning up old build..."
rm -rf build/
rm -rf docs/

echo "🏗️  Building web app..."
flutter build web --release --web-renderer canvaskit --base-href "/eat_me_first/"

echo "📂 Creating docs directory..."
mkdir -p docs

echo "📋 Copying build files to docs..."
cp -r build/web/. docs/

echo "📦 Adding changes to git..."
git add docs/

echo "💾 Committing changes..."
git commit -m "Deploy: Update web app in docs folder

- Built with web-renderer: canvaskit
- Base href: /eat_me_first/
- Deployed to docs folder for GitHub Pages"

echo "⬆️  Pushing to GitHub..."
git push origin main

echo "✅ Deployment complete!"
echo "🌎 Your app will be available at: https://pknoetze.github.io/eat_me_first/"
echo "Note: It may take a few minutes for the changes to be reflected on GitHub Pages"
