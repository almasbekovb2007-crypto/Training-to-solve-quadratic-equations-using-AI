/// Константы приложения
class AppConstants {
  // Математические константы
  static const String discriminantFormula = 'D = b² - 4ac';
  static const String rootFormula1 = 'x₁ = (-b + √D) / 2a';
  static const String rootFormula2 = 'x₂ = (-b - √D) / 2a';
  static const String rootFormulaSingle = 'x = -b / 2a';
  
  // API конфигурация
  static const String aiProviderUrl = 'https://api.deepseek.com/v1/chat/completions';
  // ВАЖНО: Замените на ваш реальный API ключ DeepSeek или используйте переменную окружения
  static const String aiProviderKey = 'sk-9d9a212a512d4d97baa525fcc44552ac';
  
  // ✅ Gemini (Google) configuration
  // Получите ключ в aistudio.google.com/apikey
  static const String geminiApiKey = 'AIzaSyDMDDbhScZo94FZklr7UpDwpf9nmmrcFUg';
  static const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';
  
  // UI константы
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 32.0;
  
  // Анимации
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Максимальные значения
  static const int maxCoefficientLength = 10;
  static const double maxCoefficientValue = 999999.0;
  
  // Точность вычислений
  static const int decimalPrecision = 4;
  static const double epsilon = 0.000001;
  
  // Сообщения об ошибках
  static const String emptyFieldError = 'Поле не может быть пустым';
  static const String invalidNumberError = 'Введите корректное число';
  static const String zeroCoefficientError = 'Коэффициент a не может быть равен нулю';
}

/// Типы решения
enum SolutionType {
  twoRealRoots,
  oneRealRoot,
  noRealRoots,
}

/// Состояния приложения
enum AppState {
  initial,
  input,
  solving,
  solved,
  error,
}
