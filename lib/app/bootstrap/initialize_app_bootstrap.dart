import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/services/fcm_service.dart';

Future<void> initializeAppBootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
  }

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('Warning: .env file not found, using default values');
  }
  debugPrint('API BASE_URL: ${ApiConstants.baseUrl}');

  await di.initializeDependencies();

  final fcmToken = await di.sl<FcmService>().initialize();
  if (fcmToken != null) {
    di.sl<di.SharedPreferences>().setString('pending_fcm_token', fcmToken);
  }
}
