import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';
import 'dart:io';

import 'data/local_db.dart';
import 'data/sync_engine.dart';
import 'screens/main_scaffold.dart';
import 'screens/login_screen.dart';
import 'screens/device_setup_screen.dart';
import 'theme/theme_provider.dart';

/// Secure storage implementation for Supabase Auth
class SecureLocalStorage extends LocalStorage {
  final storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => await storage.read(key: 'supabase_access_token');

  @override
  Future<bool> hasAccessToken() async => await storage.containsKey(key: 'supabase_access_token');

  @override
  Future<void> persistSession(String persistSessionString) async {
    await storage.write(key: 'supabase_access_token', value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await storage.delete(key: 'supabase_access_token');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register deep link protocol for Windows (poultry-pms://)
  if (Platform.isWindows) {
    _registerProtocol('poultry-pms');
  }

  // Handle deep links (OAuth redirects)
  final _appLinks = AppLinks();
  
  // 1. Handle links when app is already running
  _appLinks.uriLinkStream.listen((uri) async {
    debugPrint('Received deep link (stream): $uri');
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Session successfully retrieved from URL');
    } catch (e) {
      debugPrint('Error getting session from URL: $e');
    }
  });

  // 2. Handle link that opened the app
  final initialUri = await _appLinks.getInitialLink();
  if (initialUri != null) {
    debugPrint('Received initial deep link: $initialUri');
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
    } catch (e) {
      debugPrint('Error getting session from initial URL: $e');
    }
  }

  // Desktop Window config
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Agri-ERP Desktop',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // DB init
  final database = AppDatabase();

  // Load env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("No .env found, proceeding with defaults or placeholders");
  }

  // Supabase Init with Secure Storage
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://PLACEHOLDER.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'PLACEHOLDER',
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );

  final syncEngine = SyncEngine(database);
  
  // Check Device Binding Status
  final prefs = await SharedPreferences.getInstance();
  final bool isBound = prefs.getBool('is_bound') ?? false;

  if (isBound) {
    // Start background sync only if bound
    syncEngine.startPeriodicSync();
  }

  // Start handoff watcher for Windows
  if (Platform.isWindows) {
    _startHandoffWatcher();
  }

  final themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider<SyncEngine>.value(value: syncEngine),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MyApp(isBound: isBound),
    ),
  );
}

/// Watches for a handoff file from another instance (Windows specific)
void _startHandoffWatcher() {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null) return;

  final handoffFile = File('$localAppData\\poultry_pms_handoff.txt');
  
  // Check every 500ms
  Stream.periodic(const Duration(milliseconds: 500)).listen((_) async {
    if (await handoffFile.exists()) {
      try {
        final content = await handoffFile.readAsString();
        debugPrint('Handoff received: $content');
        
        // Clean up file immediately
        await handoffFile.delete();
        
        // Parse and exchange
        final uri = Uri.parse(content.trim());
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('Session successfully retrieved via handoff');
      } catch (e) {
        debugPrint('Error processing handoff: $e');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final bool isBound;
  const MyApp({super.key, required this.isBound});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Poultry PMS Desktop',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      home: isBound ? const LoginScreen() : const DeviceSetupScreen(),
    );
  }
}

/// Helper to register a custom protocol on Windows
void _registerProtocol(String scheme) {
  final String path = Platform.resolvedExecutable;
  
  try {
    // 1. Create the class key
    Process.runSync('reg', [
      'add', 'HKCU\\Software\\Classes\\$scheme',
      '/ve', '/t', 'REG_SZ', '/d', 'URL:$scheme Protocol', '/f'
    ]);
    
    // 2. Set URL Protocol flag
    Process.runSync('reg', [
      'add', 'HKCU\\Software\\Classes\\$scheme',
      '/v', 'URL Protocol', '/t', 'REG_SZ', '/d', '', '/f'
    ]);

    // 3. Set the command to open the app
    Process.runSync('reg', [
      'add', 'HKCU\\Software\\Classes\\$scheme\\shell\\open\\command',
      '/ve', '/t', 'REG_SZ', '/d', '"$path" "%1"', '/f'
    ]);
    
    debugPrint('Successfully registered $scheme:// protocol via reg.exe');
  } catch (e) {
    debugPrint('Failed to register protocol: $e');
  }
}

