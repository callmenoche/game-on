import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

import 'supabase_client.dart';

class BugReportService {
  static final _reports = SupabaseService.table('bug_reports');

  /// Files a report for the signed-in user. App version and platform are
  /// attached automatically. Throws on failure (RLS, rate limit, network).
  Future<void> submit({
    required String category,
    required String description,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot report a bug while signed out');
    }
    final info = await PackageInfo.fromPlatform();
    await _reports.insert({
      'user_id': userId,
      'category': category,
      'description': description,
      'app_version': '${info.version}+${info.buildNumber}',
      'platform': kIsWeb
          ? 'web'
          : '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    });
  }
}
