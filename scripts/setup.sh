#!/bin/bash

# MangaFlow Setup Script
# This script helps you set up MangaFlow locally

set -e

echo "🚀 MangaFlow Setup Script"
echo "=========================="
echo ""

# Check Node.js version
echo "📦 Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Error: Node.js 18+ is required. Current version: $(node -v)"
    echo "Please install Node.js 18 or higher from https://nodejs.org/"
    exit 1
fi
echo "✅ Node.js $(node -v) detected"
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
npm install
echo "✅ Dependencies installed"
echo ""

# Check for .env.local
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from .env.example..."
    cp .env.example .env.local
    echo "✅ .env.local created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env.local and add your API keys:"
    echo "   - NEXT_PUBLIC_SUPABASE_URL"
    echo "   - NEXT_PUBLIC_SUPABASE_ANON_KEY"
    echo "   - SUPABASE_SERVICE_ROLE_KEY"
    echo "   - BLOB_READ_WRITE_TOKEN"
    echo "   - ANTHROPIC_API_KEY (or OPENAI_API_KEY or DEEPL_API_KEY)"
    echo ""
    read -p "Press Enter after you've configured .env.local..."
else
    echo "✅ .env.local already exists"
    echo ""
fi

# Validate environment variables
echo "🔍 Validating environment variables..."
source .env.local

REQUIRED_VARS=(
    "NEXT_PUBLIC_SUPABASE_URL"
    "NEXT_PUBLIC_SUPABASE_ANON_KEY"
    "SUPABASE_SERVICE_ROLE_KEY"
    "BLOB_READ_WRITE_TOKEN"
)

MISSING_VARS=()

for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        MISSING_VARS+=("$VAR")
    fi
done

# Check for at least one translation provider
if [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$OPENAI_API_KEY" ] && [ -z "$DEEPL_API_KEY" ]; then
    MISSING_VARS+=("ANTHROPIC_API_KEY or OPENAI_API_KEY or DEEPL_API_KEY")
fi

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "❌ Missing required environment variables:"
    for VAR in "${MISSING_VARS[@]}"; do
        echo "   - $VAR"
    done
    echo ""
    echo "Please add these to .env.local and run this script again."
    exit 1
fi

echo "✅ All required environment variables are set"
echo ""

# Ask about database setup
echo "🗄️  Database Setup"
echo "=================="
echo "Have you already run the Supabase migration (supabase/migrations/0001_init.sql)?"
echo ""
echo "If not, please:"
echo "1. Go to your Supabase project"
echo "2. Open SQL Editor"
echo "3. Copy and paste the contents of supabase/migrations/0001_init.sql"
echo "4. Click 'Run'"
echo ""
read -p "Have you completed the database migration? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️  Please complete the database migration before proceeding."
    echo "   See QUICKSTART.md for detailed instructions."
    exit 1
fi

echo "✅ Database migration confirmed"
echo ""

# Summary
echo "🎉 Setup Complete!"
echo "================="
echo ""
echo "Next steps:"
echo "1. Start the development server:"
echo "   npm run dev"
echo ""
echo "2. Open http://localhost:3000 in your browser"
echo ""
echo "3. Create an account and upload your first project"
echo ""
echo "4. Manually process jobs (since cron doesn't run locally):"
echo "   curl -X POST http://localhost:3000/api/jobs/process"
echo ""
echo "For more information, see:"
echo "- QUICKSTART.md - Quick start guide"
echo "- README.md - Full documentation"
echo "- DEPLOYMENT.md - Production deployment guide"
echo ""
echo "Happy translating! 📚✨"
