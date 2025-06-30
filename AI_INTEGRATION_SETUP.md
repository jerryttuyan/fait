# Fait AI Integration – Quick Setup

## 1. Get Your OpenAI API Key

- Sign up or log in at [OpenAI](https://platform.openai.com/)
- Go to “API Keys” and create a new one
- Copy your key somewhere safe

## 2. Set Up Your Environment

**Recommended:**  
Run the setup script to create your `.env` file:
```bash
./setup_ai.sh
```
This will copy the template and walk you through the next steps.

**Or, do it manually:**  
```bash
cp env.example .env
```

Open `.env` and fill in your API key:
```
OPENAI_API_KEY=sk-your-key-here
USE_OPENAI=true
```

## 3. Install Dependencies

```bash
flutter pub get
```

## 4. Run the App

```bash
flutter run
```
Go to the AI Coach tab and try asking questions like:
- “Generate my next workout.”
- “W”

---

### Environment Variables

- `OPENAI_API_KEY` (required): Your OpenAI key
- `USE_OPENAI`: Set to `true` to enable AI
- `MAX_TOKENS`, `TEMPERATURE`, `DEFAULT_MODEL`: Optional, see `.env` for details

**Security:**  
Your `.env` is ignored by git. Never share your API key.