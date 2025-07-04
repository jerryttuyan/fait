# 🚀 Deploy AI Proxy Server to Render

## Quick Setup (5 minutes)

### Step 1: Create Proxy Server Files
The proxy server files are already created in the `ai-proxy-server/` directory.

### Step 2: Deploy to Render

1. **Go to [render.com](https://render.com)** and sign up/login
2. **Click "New +" → "Web Service"**
3. **Connect your GitHub repository** (the one containing this Fait project)
4. **Configure the service:**
   - **Name**: `fait-ai-proxy`
   - **Root Directory**: `ai-proxy-server` (important!)
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

5. **Add Environment Variables:**
   - `OPENAI_API_KEY` = your actual OpenAI API key
   - `OPENAI_MODEL` = `gpt-3.5-turbo`
   - `MAX_TOKENS` = `500`
   - `TEMPERATURE` = `0.7`

6. **Click "Create Web Service"**

### Step 3: Get Your Proxy URL
After deployment, Render will give you a URL like:
`https://fait-ai-proxy.onrender.com`

### Step 4: Update Your Flutter App
Add this to your `.env` file:
```
PROXY_SERVER_URL=https://your-app-name.onrender.com/api/ai
```

## 🎉 Done!

Your team can now:
- ✅ Use the app without seeing API keys
- ✅ You can update the API key in Render dashboard
- ✅ No backend development needed
- ✅ Free hosting

## 🔧 Testing

Test your proxy server:
```bash
curl -X POST https://your-app-name.onrender.com/api/ai \
  -H "Content-Type: application/json" \
  -d '{"question": "Hello, how are you?"}'
```

## 📱 For Your Team

Share this with your team:
1. **Clone the repo**
2. **Add the proxy URL to `.env`**
3. **Run the app**

That's it! No API keys needed in their local setup. 