import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkForUpdate(BuildContext context) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final localCode = int.tryParse(info.buildNumber) ?? 0;

    final doc = await FirebaseFirestore.instance.collection('app_meta').doc('android').get();
    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No update info available')));
      return;
    }

    final data = doc.data();
    final latest = (data?['latest_version_code'] ?? 0) as int;
    final apkUrl = (data?['apk_url'] ?? '') as String;
    final playStoreUrl = (data?['play_store_url'] ?? '') as String;
    final force = (data?['force_update'] ?? false) as bool;
    final updateUrl = apkUrl.isNotEmpty ? apkUrl : playStoreUrl;

    if (latest > localCode) {
      // show dialog
      showDialog(
        context: context,
        barrierDismissible: !force,
        builder: (ctx) => AlertDialog(
          title: const Text('Update available'),
          content: Text('A new version is available. Current: ${info.version}+${info.buildNumber}'),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (updateUrl.isNotEmpty) {
                  final uri = Uri.parse(updateUrl);
                  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!didLaunch) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open update link')),
                    );
                  }
                } else {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App is up to date')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update check failed: $e')));
  }
}
