#!/bin/bash

echo "🤖 Fait AI Integration Setup"
echo "=============================="
echo ""

# Check if .env file already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Your existing .env file is preserved."
        exit 1
    fi
fi

# Copy example file
if [ -f "env.example" ]; then
    cp env.example .env
    echo "✅ Created .env file from template"
else
    echo "❌ env.example file not found!"
    exit 1
fi

echo ""
echo "🔑 Next Steps:"
echo "1. Edit the .env file and add your OpenAI API key:"
echo "   OPENAI_API_KEY=sk-your-actual-api-key-here"
echo ""
echo "2. Enable OpenAI by setting:"
echo "   USE_OPENAI=true"
echo ""
echo "3. Run the app:"
echo "   flutter run"
echo ""
echo "🔒 Security Notes:"
echo "- The .env file is automatically excluded from git"
echo "- Never commit your API keys to version control"
echo "- Keep your .env file secure and private"
echo ""
echo "📖 For detailed instructions, see: AI_INTEGRATION_SETUP.md" 