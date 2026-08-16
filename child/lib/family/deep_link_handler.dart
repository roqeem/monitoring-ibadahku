import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Handler untuk deep link / notifikasi reminder dari guardian.
///
/// Format deep link:
///   https://ibadahku.app/open/activity/{activityKey}?reminderId={id}
///
/// Payload FCM data-only (dikirim guardian via sendStandardReminder):
///   { activityId, reminderId, templateKey }
class DeepLinkHandler {
  static final DeepLinkHandler instance = DeepLinkHandler._();
  DeepLinkHandler._();

  /// Inisialisasi listener notifikasi & link.
  Future<void> init() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onMessage);
  }

  void _onMessage(RemoteMessage msg) {
    final data = msg.data;
    final activityKey = data['activityId'];
    if (activityKey != null) {
      _showInAppBanner(activityKey, data['reminderId']);
    }
    // Show a local notification (delegated to reminder service)
  }

  /// Show a banner / toast when a reminder FCM arrives in foreground.
  void _showInAppBanner(String activityKey, String? reminderId) {
    // In a full impl: showSnackBar or local notification with reminder preferences
    debugPrint('Family reminder received: activity=$activityKey, reminderId=$reminderId');
  }

  /// Resolve activity key to timeline position for scroll-to-item.
  /// Returns (sectionId, itemId) or null if not found.
  (String, String)? resolveActivity(BuildContext context, String activityKey) {
    final state = context.read<AppState>();
    final today = state.currentDate;
    final timeline = state.timeline(today);
    for (final section in timeline) {
      for (final item in section.items) {
        if (item.id.endsWith(':$activityKey') ||
            item.prayerName == activityKey ||
            item.sunnahType == activityKey ||
            item.dhikrContentId == activityKey) {
          return (section.id, item.id);
        }
      }
    }
    return null;
  }

  /// Scroll to the given section on the timeline and highlight the item.
  void navigateToActivity(BuildContext context, String activityKey) {
    final resolved = resolveActivity(context, activityKey);
    if (resolved == null) {
      // Scroll to top and show a hint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas belum tersedia pada tanggal ini.')),
      );
      return;
    }
    // In full impl: use scroll controller to jump to TimelineSection
    debugPrint('Navigate to section ${resolved.$1}, item ${resolved.$2}');
  }
}