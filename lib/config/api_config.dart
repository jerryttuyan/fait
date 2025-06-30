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
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Validate that required environment variables are set
  static bool validateConfig() {
    if (useOpenAI && openaiApiKey.isEmpty) {
      print('⚠️  Warning: OpenAI is enabled but API key is not set in .env file');
      print('   To fix this:');
      print('   1. Run: ./setup_ai.sh');
      print('   2. Edit .env file and add your OpenAI API key');
      print('   3. Set USE_OPENAI=true');
      return false;
    }
    return true;
  }
} 