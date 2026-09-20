// /lib/core/updater_service.dart

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'http_client.dart';

class UpdaterService {
  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await HttpClient().dio.get('/api/system/update-check');
      final data = response.data;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Basic string comparison (Consider a proper semver package for production)
      if (data['latest_version'] != currentVersion) {
        return data;
      }
    } catch (e) {
      // Fail silently on network errors so the app still works offline
    }
    return null;
  }

  static Future<void> downloadAndInstall(
    String url,
    Function(double) onProgress,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/bossgrad_update.apk';

      // Download the APK using Dio
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // Trigger the Android OS Package Installer
      await OpenFilex.open(savePath);
    } catch (e) {
      throw Exception('Failed to download update: $e');
    }
  }
}
