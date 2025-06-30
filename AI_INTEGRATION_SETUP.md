# AI Integration Setup Guide

## Overview

The Fait app now includes real AI integration using OpenAI's API with **secure environment variable management**. The system uses a hybrid approach:

- **Hard-coded responses** for structured requests (workout plans, nutrition calculations, etc.)
- **OpenAI API** for natural language conversations and complex questions
- **Automatic fallback** to hard-coded responses if the API fails
- **Secure API key management** using environment variables

## Security First Setup

### 1. Get an OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to "API Keys" in the left sidebar
4. Click "Create new secret key"
5. Copy the generated API key (keep it secure!)

### 2. Set Up Environment Variables

1. **Copy the example file:**
   ```bash
   cp env.example .env
   ```

2. **Edit the .env file** with your actual API key:
   ```bash
   # AI Service Configuration
   OPENAI_API_KEY=sk-your-actual-api-key-here
   USE_OPENAI=true
   
   # API Settings
   MAX_TOKENS=500
   TEMPERATURE=0.7
   DEFAULT_MODEL=gpt-3.5-turbo
   ```

3. **Important Security Notes:**
   - The `.env` file is automatically excluded from version control
   - Never commit your actual API keys to git
   - Keep your `.env` file secure and don't share it

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Test the Integration

1. Run the app: `flutter run`
2. Navigate to the AI Coach tab
3. Try asking natural language questions like:
   - "I'm feeling tired after workouts, what should I do?"
   - "How can I improve my bench press?"
   - "What's the best time to work out?"

## Environment Variable Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | Your OpenAI API key | `sk-abc123...` |
| `USE_OPENAI` | Enable/disable OpenAI | `true` or `false` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MAX_TOKENS` | Maximum response length | `500` |
| `TEMPERATURE` | Creativity level (0.0-1.0) | `0.7` |
| `DEFAULT_MODEL` | OpenAI model to use | `gpt-4o` |

### Example .env File

```bash
# AI Service Configuration
OPENAI_API_KEY=sk-your-actual-api-key-here
USE_OPENAI=true

# API Settings
MAX_TOKENS=500
TEMPERATURE=0.7
DEFAULT_MODEL=gpt-4o

# Future AI Services
ANTHROPIC_API_KEY=your_anthropic_key_here
GEMINI_API_KEY=your_gemini_key_here
```