import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

class ForumHeaderNotificationMenuItem extends StatefulWidget {
  const ForumHeaderNotificationMenuItem({
    super.key,
    required this.postId,
    this.subCategory,
  });

  final String postId;
  final String? subCategory;

  @override
  State<ForumHeaderNotificationMenuItem> createState() =>
      _ForumHeaderNotificationMenuItemState();
}

class _ForumHeaderNotificationMenuItemState
    extends State<ForumHeaderNotificationMenuItem> {
  /// Firebase Database 인스턴스
  /// Firebase Database instance
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// 스트림 캐시 (Stream cache to prevent recreation on scroll)
  /// Cache streams to maintain state when ListView rebuilds items during scroll
  final Map<String, Stream<bool>> _streamCache = {};

  /// 현재 사용자 UID 가져오기
  /// Get current user UID
  String? get _currentUserUid => fa.FirebaseAuth.instance.currentUser?.uid;

  /// FCM 구독 경로 가져오기
  /// Get FCM subscription path
  String _getFcmPath(String majorId, {String? subCategory}) {
    if (subCategory != null) {
      /// '/'를 '-'로 변환 (Firebase 경로에서 '/'는 사용 불가)
      /// Replace '/' with '-' (Firebase path cannot contain '/')
      final sanitizedSubCategory = subCategory.replaceAll('/', '-');
      return 'fcm-subscriptions/-forum-$majorId-$sanitizedSubCategory';
    }
    return 'fcm-subscriptions/-forum-$majorId';
  }

  /// Firebase에서 구독 상태 토글
  /// Toggle subscription state in Firebase
  Future<void> _toggleSubscription(String postId, {String? subCategory}) async {
    if (_currentUserUid == null) return;

    final path = _getFcmPath(postId, subCategory: subCategory);
    final ref = _database.ref('$path/$_currentUserUid');

    try {
      final snapshot = await ref.get();
      final currentValue = snapshot.value as bool?;

      /// 현재 값의 반대로 설정 (true ↔ false)
      /// Set to opposite of current value (true ↔ false)
      await ref.set(!(currentValue ?? false));
    } catch (e) {
      debugPrint('Error toggling subscription: $e');
    }
  }

  /// Firebase에서 구독 상태 스트림 가져오기
  /// Get subscription state stream from Firebase
  /// Returns a cached broadcast stream to maintain state during scrolling
  Stream<bool> _getSubscriptionStream(String postId, {String? subCategory}) {
    if (_currentUserUid == null) {
      return Stream.value(false);
    }

    /// Create unique cache key for this category
    final cacheKey = subCategory != null ? '$postId-$subCategory' : postId;

    /// Return cached stream if it exists, otherwise create and cache new stream
    /// This prevents stream recreation when ListView rebuilds items during scroll
    return _streamCache.putIfAbsent(cacheKey, () {
      final path = _getFcmPath(postId, subCategory: subCategory);
      final ref = _database.ref('$path/$_currentUserUid');

      /// Convert to broadcast stream to allow multiple listeners
      /// This prevents "Stream has already been listened to" error
      return ref.onValue.map((event) {
        if (!event.snapshot.exists) return false;
        return event.snapshot.value as bool? ?? false;
      }).asBroadcastStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final localizedName = philgoTr(
      context,
      widget.subCategory ?? widget.postId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<bool>(
          stream: _getSubscriptionStream(
            widget.postId,
            subCategory: widget.subCategory,
          ),
          builder: (context, snapshot) {
            final isSelected = snapshot.data ?? false;

            return InkWell(
              /// 서브 카테고리가 없으면 토글
              /// If no subcategories, toggle selection
              onTap: () => _toggleSubscription(
                widget.postId,
                subCategory: widget.subCategory,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s8,
                  vertical: sp.s12,
                ),
                child: Row(
                  children: [
                    /// 체크박스 아이콘
                    /// Checkbox icon
                    FaIcon(
                      isSelected
                          ? FontAwesomeIcons.solidBellRing
                          : FontAwesomeIcons.lightBell,
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      size: 20,
                    ),

                    SizedBox(width: sp.s12),

                    /// 카테고리 이름
                    /// Category name
                    Expanded(
                      child: Text(
                        localizedName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? scheme.primary : scheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        /// 구분선
        /// Divider
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ],
    );
  }
}
