import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> checkForUpdate(BuildContext context) async {
  if (!context.mounted) return false;

  try {
    final info = await PackageInfo.fromPlatform();
    final localVersion = info.version;

    final doc = await FirebaseFirestore.instance.collection('app_meta').doc('android').get();
    if (!doc.exists || !context.mounted) {
      return true;
    }

    final data = doc.data();
    final latestCode = _parseInt(data?['latest_version_code']) ?? 0;
    final latestVersionName = (data?['latest_version_name'] ?? info.version).toString();
    final apkUrl = (data?['apk_url'] ?? data?['download_url'] ?? data?['update_url'] ?? '') as String;
    final playStoreUrl = (data?['play_store_url'] ?? '') as String;
    final force = _parseBool(data?['force_update']);
    final updateUrl = _buildUpdateUrl(apkUrl.isNotEmpty ? apkUrl : playStoreUrl);
    final shouldUpdate = shouldShowUpdate(
      currentVersion: localVersion,
      currentBuildNumber: info.buildNumber,
      latestVersionName: latestVersionName,
      latestVersionCode: latestCode,
    );

    if (shouldUpdate) {
      if (!context.mounted) return false;

      final shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: !force,
        builder: (ctx) => AlertDialog(
          title: const Text('Update available'),
          content: Text(
            'A new version is ready to install.\n\nCurrent: ${info.version}+${info.buildNumber}\nLatest: $latestVersionName+$latestCode',
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop(false);
                if (!context.mounted) return;

                if (updateUrl.isNotEmpty) {
                  final uri = Uri.parse(updateUrl);
                  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!didLaunch && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open update link')),
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Update URL not provided')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );

      if (!context.mounted) return false;
      return shouldContinue ?? (!force);
    }

    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update check failed: $e')));
    }
    return true;
  }
}

bool shouldShowUpdate({
  required String currentVersion,
  required String currentBuildNumber,
  required String latestVersionName,
  required int latestVersionCode,
}) {
  final localCode = int.tryParse(currentBuildNumber) ?? 0;
  if (latestVersionCode > localCode) {
    return true;
  }

  final versionCompare = _compareVersions(currentVersion, latestVersionName);
  return versionCompare < 0;
}

int _compareVersions(String currentVersion, String latestVersionName) {
  final currentParts = currentVersion.split('.').map(int.tryParse).toList();
  final latestParts = latestVersionName.split('.').map(int.tryParse).toList();
  final length = currentParts.length > latestParts.length ? currentParts.length : latestParts.length;

  for (var i = 0; i < length; i++) {
    final currentValue = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
    final latestValue = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
    if (latestValue > currentValue) return -1;
    if (latestValue < currentValue) return 1;
  }

  return 0;
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

String _buildUpdateUrl(String candidate) {
  if (candidate.isEmpty) return '';

  final uri = Uri.tryParse(candidate);
  if (uri == null) return candidate;

  if (!uri.host.contains('drive.google.com')) {
    return candidate;
  }

  final fileIdMatch = RegExp(r'/file/d/([^/]+)').firstMatch(uri.path);
  if (fileIdMatch != null) {
    return 'https://drive.google.com/uc?export=download&id=${fileIdMatch.group(1)}';
  }

  final queryFileId = uri.queryParameters['id'];
  if (queryFileId != null && queryFileId.isNotEmpty) {
    return 'https://drive.google.com/uc?export=download&id=$queryFileId';
  }

  return candidate;
}
