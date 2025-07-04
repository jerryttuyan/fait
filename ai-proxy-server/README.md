# Fait AI Proxy Server

A simple Node.js proxy server for the Fait fitness app that securely handles OpenAI API calls.

## 🚀 Quick Deploy to Render

### Option 1: Deploy from GitHub (Recommended)

1. **Fork this repository** or add these files to your existing Fait repo
2. **Go to [render.com](https://render.com)** and create an account
3. **Click "New +" → "Web Service"**
4. **Connect your GitHub repository**
5. **Configure the service:**
   - **Name**: `fait-ai-proxy`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

6. **Add Environment Variables:**
   - `OPENAI_API_KEY` = your actual OpenAI API key
   - `OPENAI_MODEL` = `gpt-3.5-turbo` (or your preferred model)
   - `MAX_TOKENS` = `500`
   - `TEMPERATURE` = `0.7`

7. **Click "Create Web Service"**

### Option 2: Deploy from Local Files

1. **Create a new directory** for the proxy server
2. **Copy these files** into it
3. **Push to GitHub**
4. **Follow steps 2-7 above**

## 🔧 Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create `.env` file:**
   ```bash
   cp env.example .env
   # Edit .env with your OpenAI API key
   ```

3. **Run locally:**
   ```bash
   npm run dev
   ```

4. **Test the endpoint:**
   ```bash
   curl -X POST http://localhost:3000/api/ai \
     -H "Content-Type: application/json" \
     -d '{"question": "Hello, how are you?"}'
   ```

## 📱 Update Your Flutter App

After deploying, update your Flutter app to use the proxy server:

```dart
// In your AIService class
Future<String> getAIResponse(String question, {List<Map<String, String>>? chatHistory}) async {
  // ... your existing context building code ...
  
  try {
    final response = await http.post(
      Uri.parse('https://your-render-url.onrender.com/api/ai'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'chatHistory': chatHistory,
        'userContext': {
          'contextString': contextString,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to get AI response');
    }
  } catch (e) {
    // Fallback to hardcoded response
    return await _getHardcodedResponse(question, context);
  }
}
```

## 🔒 Security Features

- ✅ API keys stored securely in environment variables
- ✅ CORS enabled for cross-origin requests
- ✅ Input validation
- ✅ Error handling and logging
- ✅ Rate limiting (can be added if needed)

## 📊 Monitoring

- **Health check**: `GET /health`
- **Logs**: Available in Render dashboard
- **Usage tracking**: Optional usage data in responses

## 💰 Cost

- **Free tier**: 750 hours/month
- **Typical usage**: ~$0-5/month for a small team
- **Scaling**: Easy to upgrade if needed

## 🛠️ Customization

You can easily modify the server to:
- Add authentication
- Implement rate limiting
- Add caching
- Support multiple AI providers
- Add analytics tracking 