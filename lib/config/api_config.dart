class ApiConfig {
  // Proxy Server Configuration
  static String get proxyServerUrl => 'https://fait-ai-proxy.onrender.com/api/ai';
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration requestTimeout = Duration(seconds: 30);
}