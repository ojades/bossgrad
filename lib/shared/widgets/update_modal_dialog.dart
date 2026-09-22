import 'package:flutter/material.dart';

import '../../core/theme/boss_theme.dart';
import '../../core/updater_service.dart';

class UpdateModalDialog extends StatefulWidget {
  final Map<String, dynamic> updateData;

  const UpdateModalDialog({super.key, required this.updateData});

  /// Helper method to cleanly run the check and show the dialog if an update exists.
  static Future<void> checkAndShow(
    BuildContext context, {
    bool showUpToDateMessage = false,
  }) async {
    final updateData = await UpdaterService.checkForUpdate();

    if (!context.mounted) return;

    if (updateData != null) {
      final bool forceUpdate = updateData['force_update'] ?? false;

      showDialog(
        context: context,
        barrierDismissible: !forceUpdate,
        builder: (dialogContext) {
          return PopScope(
            canPop: !forceUpdate,
            child: UpdateModalDialog(updateData: updateData),
          );
        },
      );
    } else if (showUpToDateMessage) {
      // Show feedback only if specifically requested
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your app is already up to date! 🎉',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          backgroundColor: Color(0xFF28C995), // Success green
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  State<UpdateModalDialog> createState() => _UpdateModalDialogState();
}

class _UpdateModalDialogState extends State<UpdateModalDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      await UpdaterService.downloadAndInstall(
        widget.updateData['download_url'],
        (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = 'Download failed. Check connection and retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BossGradTheme>()!;
    final bool forceUpdate = widget.updateData['force_update'] ?? false;
    final String version = widget.updateData['latest_version'] ?? '1.0.0';
    final String releaseNotes =
        widget.updateData['release_notes'] ??
        'New features and arena improvements available!';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE5D9F4), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD8C9EB), offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: theme.primaryAction,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW VERSION AVAILABLE',
                        style: TextStyle(
                          color: theme.primaryAction,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        'Update v$version',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF241642),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              releaseNotes,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF697386),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFFF6578),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFEEE8FF),
                  color: theme.primaryAction,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Downloading... ${(_progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF756B91),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  if (!forceUpdate) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Later',
                          style: TextStyle(
                            color: Color(0xFF756B91),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryAction,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
