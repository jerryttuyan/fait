import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // OpenAI Configuration
  static String get openaiApiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  static bool get useOpenAI {
    try {
      return dotenv.env['USE_OPENAI'] == 'true';
    } catch (e) {
      return false;
    }
  }
  
  // Alternative AI Services (for future use)
  static String get anthropicApiKey {
    try {
      return dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  static String get geminiApiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  // API Settings
  static int get maxTokens {
    try {
      return int.tryParse(dotenv.env['MAX_TOKENS'] ?? '500') ?? 500;
    } catch (e) {
      return 500;
    }
  }
  
  static double get temperature {
    try {
      return double.tryParse(dotenv.env['TEMPERATURE'] ?? '0.7') ?? 0.7;
    } catch (e) {
      return 0.7;
    }
  }
  
  static String get defaultModel {
    try {
      return dotenv.env['DEFAULT_MODEL'] ?? 'gpt-3.5-turbo';
    } catch (e) {
      return 'gpt-3.5-turbo';
    }
  }
  
  // Proxy Server Configuration
  static String get proxyServerUrl {
    try {
      return dotenv.env['PROXY_SERVER_URL'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Validate that required environment variables are set
  static bool validateConfig() {
    if (useOpenAI) {
      if (openaiApiKey.isEmpty && proxyServerUrl.isEmpty) {
        print('⚠️  Warning: OpenAI is enabled but neither API key nor proxy server URL is set');
        print('   To fix this:');
        print('   1. Option A - Use proxy server (recommended for group projects):');
        print('      - Deploy the proxy server to Render');
        print('      - Add PROXY_SERVER_URL=https://your-app.onrender.com/api/ai to .env');
        print('   2. Option B - Use direct OpenAI:');
        print('      - Run: ./setup_ai.sh');
        print('      - Edit .env file and add your OpenAI API key');
        print('      - Set USE_OPENAI=true');
        return false;
      }
    }
    return true;
  }
} 