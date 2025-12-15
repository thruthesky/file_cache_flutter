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

  /// 로컬 구독 상태 (one-time read를 통해 초기화되며, 탭 시 토글됨)
  /// Local subscription state (initialized via one-time read, toggled on tap)
  /// This prevents 25+ continuous stream listeners which cause crashes
  bool _isSubscribed = false;

  /// 로딩 상태
  /// Loading state for initial data fetch
  bool _isLoading = true;

  /// 현재 사용자 UID 가져오기
  /// Get current user UID
  String? get _currentUserUid => fa.FirebaseAuth.instance.currentUser?.uid;

  String get sanitizedSubCategory => widget.subCategory != null
      ? widget.subCategory!.replaceAll('/', '-')
      : '';

  /// FCM 구독 경로 가져오기
  /// Get FCM subscription path
  String _getFcmPath() {
    if (widget.subCategory != null) {
      /// '/'를 '-'로 변환 (Firebase 경로에서 '/'는 사용 불가)
      /// Replace '/' with '-' (Firebase path cannot contain '/')
      return 'fcm-subscriptions/-forum-${widget.postId}-$sanitizedSubCategory';
    }
    return 'fcm-subscriptions/-forum-${widget.postId}';
  }

  @override
  void initState() {
    super.initState();
    _loadInitialSubscriptionState();
  }

  /// Firebase에서 초기 구독 상태를 한 번만 읽어옴
  /// Load initial subscription state from Firebase once
  /// This prevents creating continuous listeners for each category
  Future<void> _loadInitialSubscriptionState() async {
    if (_currentUserUid == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final path = _getFcmPath();
    final ref = _database.ref('$path/$_currentUserUid');

    try {
      final event = await ref.once();
      if (mounted) {
        setState(() {
          _isSubscribed = event.snapshot.value as bool? ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading subscription state: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Firebase에서 구독 상태 토글 (로컬 상태도 즉시 업데이트)
  /// Toggle subscription state in Firebase (update local state immediately)
  Future<void> _toggleSubscription() async {
    if (_currentUserUid == null) return;

    /// 즉시 로컬 상태를 토글하여 UI 반응성 향상
    /// Immediately toggle local state for better UI responsiveness
    setState(() {
      _isSubscribed = !_isSubscribed;
    });

    final path = _getFcmPath();
    final ref = _database.ref('$path/$_currentUserUid');

    try {
      /// Firebase에 새로운 값 저장
      /// Save new value to Firebase
      await ref.set(_isSubscribed);
    } catch (e) {
      debugPrint('Error toggling subscription: $e');

      /// 에러 발생 시 로컬 상태를 원래대로 복원
      /// Revert local state if error occurs
      if (mounted) {
        setState(() {
          _isSubscribed = !_isSubscribed;
        });
      }
    }
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
        InkWell(
          /// 탭하여 구독 상태 토글
          /// Tap to toggle subscription state
          onTap: _isLoading ? null : _toggleSubscription,
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
                  _isSubscribed
                      ? FontAwesomeIcons.solidBellRing
                      : FontAwesomeIcons.lightBell,
                  color: _isSubscribed
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
                      color: _isSubscribed ? scheme.primary : scheme.onSurface,
                      fontWeight:
                          _isSubscribed ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// 구분선
        /// Divider
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ],
    );
  }
}
