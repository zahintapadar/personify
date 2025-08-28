#!/bin/bash

# Personify Build Script with Secure Configuration

echo "🔐 Building Personify with secure configuration..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Please copy .env.example to .env and configure your API keys"
    exit 1
fi

# Source environment variables
set -a
source .env
set +a

# Validate required variables
if [ -z "$GEMINI_API_KEY" ] || [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: Missing required environment variables in .env"
    echo "📝 Please check your .env file contains all required keys"
    exit 1
fi

echo "✅ Environment variables validated"

# Build the APK with secure configuration
echo "🏗️  Building APK..."
flutter build apk \
    --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

if [ $? -eq 0 ]; then
    echo "🎉 Build completed successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Build failed!"
    exit 1
fi
