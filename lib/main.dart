import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/database_service.dart';
import 'services/social_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Immersive sticky mode - hide navigation bar, swipe to show temporarily
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  
  // Initialize Turkish locale for date formatting
  await initializeDateFormatting('tr_TR', null);
  
  // Initialize database
  try {
    await DatabaseService.init();
  } catch (e) {
    debugPrint('Database init error: $e');
    // Continue running app even if DB fails, or show error screen
  }

  // Initialize social standards service
  await SocialService.init();
  
  runApp(const FOPRApp());
}
