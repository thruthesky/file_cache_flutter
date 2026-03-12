import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:philgo/api/api.service.dart';
import 'package:philgo/user/edit/widgets/user_avatar_with_upload_icon.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/user.state.dart';

/// 프로필 편집 화면
///
/// - 섹션 인디케이터 바 + 타이틀 헤더
/// - 포인트/레벨 칩
/// - 전화번호 표시 (읽기 전용)
/// - 닉네임, 이름
/// - 성별 선택
class UserEditScreen extends StatefulWidget {
  static const String routeName = '/user/edit';
  static void push(BuildContext context) => context.push(routeName);

  const UserEditScreen({super.key});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();
  String? _photoUrl;
  int? _uploadedFileIdx; // 새로 업로드한 파일 idx (삭제 시 사용)
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserState>().user;
    _nicknameController.text = user?.nickname ?? '';
    _nameController.text = user?.name ?? '';
    _photoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('닉네임을 입력해 주세요.'.tr())));
      return;
    }

    final userIdx = context.read<UserState>().user?.idx;
    if (userIdx == null) return;

    setState(() => _saving = true);
    try {
      final updated = await UserService.updateProfile(
        idx: userIdx,
        nickname: _nicknameController.text.trim(),
        name: _nameController.text.trim(),
        photoUrl: _photoUrl,
      );
      if (!mounted) return;
      context.read<UserState>().setUser(updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로필이 저장되었습니다.'.tr())));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = context.watch<UserState>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 편집'.tr(), style: theme.textTheme.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _save,
              icon: const FaIcon(FontAwesomeIcons.check),
              tooltip: '저장'.tr(),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// [1] 프로필 사진 섹션
              _buildSection(
                title: '프로필 사진'.tr(),
                icon: FontAwesomeIcons.camera,
                child: Center(
                  child: UserAvatarWithUploadIcon(
                    photoUrl: _photoUrl,
                    size: 120,
                    onUploaded: (model) async {
                      // 이전 캐시 무효화
                      final oldUrl = _photoUrl;
                      if (oldUrl != null &&
                          oldUrl.isNotEmpty &&
                          oldUrl != model.url) {
                        await CachedNetworkImage.evictFromCache(oldUrl);
                      }
                      await CachedNetworkImage.evictFromCache(model.url);
                      if (!mounted) return;
                      setState(() {
                        _photoUrl = model.url;
                        _uploadedFileIdx = model.idx;
                      });
                      // 업로드 즉시 프로필 저장
                      final idx = context.read<UserState>().user?.idx;
                      if (idx == null) return;
                      final updated = await UserService.updateProfile(
                        idx: idx,
                        photoUrl: model.url,
                      );
                      if (context.mounted) {
                        UserState.of(context).setUser(updated);
                      }
                    },
                    onTapDelete: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('사진을 삭제하는 중...'.tr()),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      final oldUrl = _photoUrl;
                      final fileIdx = _uploadedFileIdx;
                      if (oldUrl != null && oldUrl.isNotEmpty) {
                        await CachedNetworkImage.evictFromCache(oldUrl);
                      }
                      // 파일 삭제 API 호출
                      if (fileIdx != null) {
                        await ApiService.fileDelete(fileIdx);
                      }
                      // 프로필에서 사진 제거
                      final idx = context.read<UserState>().user?.idx;
                      if (idx == null) return;
                      final updated = await UserService.updateProfile(
                        idx: idx,
                        photoUrl: '',
                      );
                      if (context.mounted) {
                        UserState.of(context).setUser(updated);
                      }

                      if (mounted) {
                        setState(() {
                          _photoUrl = null;
                          _uploadedFileIdx = null;
                        });
                      }
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              /// 포인트 / 레벨 칩
              if (user != null)
                Row(
                      children: [
                        Expanded(
                          child: _buildStatChip(
                            icon: FontAwesomeIcons.coins,
                            label: '포인트'.tr(),
                            value:
                                '${NumberFormat('#,###').format(user.point)}P',
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatChip(
                            icon: FontAwesomeIcons.trophy,
                            label: '레벨'.tr(),
                            value: 'Lv.${user.level}',
                            color: scheme.tertiary,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 50.ms)
                    .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              /// [2] 기본 정보 섹션
              _buildSection(
                    title: '기본 정보'.tr(),
                    icon: FontAwesomeIcons.user,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 닉네임
                        _buildFieldLabel('닉네임'.tr(), FontAwesomeIcons.at),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            hintText: '닉네임을 입력하세요.'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 이름
                        _buildFieldLabel('이름'.tr(), FontAwesomeIcons.idCard),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '이름을 입력하세요.'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              /// [3] 저장 버튼
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  scheme.onPrimary,
                                ),
                              ),
                            )
                          : const FaIcon(FontAwesomeIcons.floppyDisk, size: 18),
                      label: Text(
                        '저장'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
