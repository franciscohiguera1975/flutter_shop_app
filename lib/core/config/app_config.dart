// lib/core/config/app_config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  static const String appName = 'Flutter Shop App';
  static const double taxRate = 0.15; // IVA Ecuador 15 %
}