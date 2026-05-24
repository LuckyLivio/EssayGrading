class AppConstants {
  static const String appName = '申论批改官';
  static const String settingsBox = 'settingsBox';
  static const String historyBox = 'historyBox';
  
  // Settings keys
  static const String keyApiUrl = 'apiUrl';
  static const String keyApiKey = 'apiKey';
  static const String keyModel = 'model';
  static const String keyStrictness = 'strictness'; // 0: 宽松, 1: 适中, 2: 严格

  // Default settings
  static const String defaultApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String defaultModel = 'gpt-4o';
}
