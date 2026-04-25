import 'package:supabase_flutter/supabase_flutter.dart';

class TawkService {
  static final TawkService _instance = TawkService._internal();
  factory TawkService() => _instance;
  TawkService._internal();

  // Your actual Tawk.to credentials
  static const String _propertyId = '69d00d4cb8aa781c3b30fd42';
  static const String _widgetId = '1jlab7tqf';

  // Get the direct Tawk.to chat page URL
  String getDirectChatUrl() {
    return 'https://tawk.to/chat/$_propertyId/$_widgetId';
  }

  // Check if user is logged in
  bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  // Get user display name
  String getUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.email?.split('@')[0] ??
        'Guest User';
  }

  // Get user email
  String getUserEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email ?? 'guest@example.com';
  }
}
