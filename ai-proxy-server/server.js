const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Fait AI Proxy Server is running' });
});

// Main AI proxy endpoint
app.post('/api/ai', async (req, res) => {
  try {
    const { question, chatHistory, userContext } = req.body;

    // Validate input
    if (!question) {
      return res.status(400).json({ error: 'Question is required' });
    }

    // Get API key from environment
    const openaiApiKey = process.env.OPENAI_API_KEY;
    if (!openaiApiKey) {
      console.error('OpenAI API key not configured');
      return res.status(500).json({ error: 'AI service not configured' });
    }

    // Build context string
    const contextString = userContext?.contextString || "You are the AI Coach in the Fait app.";

    // Build the prompt
    const prompt = `
${contextString}

User Question: ${question}

As Fait's AI Coach, you are a friendly, knowledgeable, and concise fitness assistant inside the Fait app. Always be helpful, positive, and encouraging, but keep your responses brief and to the point. Use the user's data and context to personalize advice. If you provide a workout plan, give a short, natural explanation, then only include the JSON array of the plan. Do not list the workout in Markdown, text, or any other format. Never show the workout plan twice. Never omit the JSON array. Do not mention JSON, code, or formatting in your user-facing responses.

Example workout plan format (do not mention this to the user):
[
  {"name": "Barbell Bench Press", "sets": 3, "reps": 8, "weight": 95, "notes": ""},
  {"name": "Dumbbell Row", "sets": 3, "reps": 10, "weight": 30, "notes": ""}
]
`;

    // Build messages array
    const messages = [
      {
        role: 'system',
        content: "You are Fait's AI Coach, a friendly, knowledgeable, and concise fitness assistant inside the Fait app. Always be helpful, positive, and encouraging, but keep your responses brief and to the point. Use the user's data and context to personalize advice. If you provide a workout plan, give a short, natural explanation, then only include the JSON array of the plan. Do not list the workout in Markdown, text, or any other format. Never show the workout plan twice. Never omit the JSON array. Do not mention JSON, code, or formatting in your user-facing responses."
      },
      ...(chatHistory || []),
      {
        role: 'user',
        content: prompt,
      }
    ];

    // Call OpenAI API
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: process.env.OPENAI_MODEL || 'gpt-3.5-turbo',
        messages: messages,
        max_tokens: parseInt(process.env.MAX_TOKENS) || 500,
        temperature: parseFloat(process.env.TEMPERATURE) || 0.7,
      }),
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('OpenAI API error:', response.status, errorData);
      throw new Error(`OpenAI API error: ${response.status} - ${errorData}`);
    }

    const data = await response.json();
    const aiResponse = data.choices[0].message.content;

    res.json({ 
      response: aiResponse,
      usage: data.usage // Optional: for monitoring
    });

  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ 
      error: 'Failed to get AI response',
      details: error.message 
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Fait AI Proxy Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
}); 