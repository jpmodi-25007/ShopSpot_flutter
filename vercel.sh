#!/bin/bash

# Download Flutter SDK
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b 3.22.3

# Add flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Pre-download dependencies
echo "Pre-downloading flutter dependencies..."
flutter precache

# Get dependencies
echo "Getting packages..."
flutter pub get

# Build web application with dynamic environment variables
echo "Building Flutter Web App..."
if [ -z "$NEXT_PUBLIC_API_URL" ]; then
  # Fallback to local network IP if env variable is not set (useful for local Vercel CLI testing)
  echo "NEXT_PUBLIC_API_URL is not set. Using local development URL."
  flutter build web --release --dart-define=BASE_URL=http://192.168.0.38:3001/api/v1 --dart-define=WEB_BASE_URL=https://shopspot.local
else
  # Use Vercel's provided URL for production
  echo "Building for production API: $NEXT_PUBLIC_API_URL"
  
  # Set the web URL to the Vercel project domain if available
  WEB_URL="https://$VERCEL_PROJECT_PRODUCTION_URL"
  if [ -z "$VERCEL_PROJECT_PRODUCTION_URL" ]; then
    WEB_URL="https://findivo.vercel.app" # Default fallback
  fi
  
  flutter build web --release --dart-define=BASE_URL=$NEXT_PUBLIC_API_URL --dart-define=WEB_BASE_URL=$WEB_URL
fi
