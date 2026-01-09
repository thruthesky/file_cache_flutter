import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';
import 'package:philgo/widgets/theme/comic_snackbar.dart';

/// Profile Edit Screen (프로필 수정 화면)
///
/// Allows users to edit their profile information including:
/// - Profile photo
/// - Nickname
/// - Full name
/// - Birth date
/// - Gender
///
/// Design follows menu.home.dart style:
/// - Section indicator bar + title header
/// - surfaceContainerLowest background
/// - outlineVariant border
/// - 28px spacing between sections
class ProfileEditScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  int birthDate = 0;
  String? gender = "M";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(T.editProfile, style: theme.textTheme.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: UserReady(
        init: (context, user) async {
          _nicknameController.text = user.nickname;
          _nameController.text = user.name;
          gender = user.gender;
          birthDate = user.birthDate;
          setState(() {});
        },
        login: (context, user) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 28,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  /// [1. Profile Photo Section] - 프로필 사진 섹션
                  /// Hero 애니메이션: 퀵 메뉴의 아바타와 연결
                  /// Hero animation: Connected with quick menu avatar
                  _buildSection(
                    title: T.profilePhoto,
                    icon: FontAwesomeIcons.camera,
                    child: Center(
                      child: FileUpload(
                        deleteFile: user.photoUrl,
                        file: true,
                        video: true,
                        onUploaded: (url) async {
                          log('uploaded file url: $url');

                          // Get the old photo URL before updating
                          // 이전 사진 URL을 업데이트 전에 가져옴
                          final oldPhotoUrl =
                              PhilgoState.of(context).user?.photoUrl;

                          final updatedUser = await philgoApiUserUpdate({
                            'photo_url': url,
                          });

                          if (context.mounted) {
                            // Store PhilgoState reference before async operations
                            // async 작업 전에 PhilgoState 참조 저장
                            final philgoState = PhilgoState.of(context);

                            // Evict old image from cache to ensure new image is displayed
                            // 새 이미지가 표시되도록 이전 이미지 캐시 삭제
                            if (oldPhotoUrl != null &&
                                oldPhotoUrl.isNotEmpty &&
                                oldPhotoUrl != url) {
                              await CachedNetworkImage.evictFromCache(
                                oldPhotoUrl,
                              );
                            }

                            // Also evict new URL cache in case same URL is reused
                            // 동일 URL이 재사용되는 경우를 대비해 새 URL 캐시도 삭제
                            await CachedNetworkImage.evictFromCache(url);

                            // Update user state (PhilgoState reference captured before async)
                            // 사용자 상태 업데이트 (async 전에 캡처한 PhilgoState 참조 사용)
                            philgoState.setUser(updatedUser);

                            if (context.mounted) {
                              showComicSuccessSnackBar(
                                context,
                                T.profilePhotoUpdated,
                              );
                            }
                          }
                        },
                        onBeforeUpload: () => log('before upload'),
                        onCancelled: () => log('upload cancelled'),
                        child: Hero(
                          /// Hero 태그: 퀵 메뉴 아바타와 동일한 태그
                          /// Hero tag: Same tag as quick menu avatar
                          tag: 'profile-photo-hero',
                          child: UserAvatarWithUploadIcon(
                            size: 120,
                            user: user,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.center,
                            onTapDelete: () async {
                              try {
                                // Store photo URL before deletion for cache eviction
                                // 캐시 삭제를 위해 삭제 전에 사진 URL 저장
                                final oldPhotoUrl =
                                    PhilgoState.of(context).user!.photoUrl;

                                await philgoApiFileDelete(oldPhotoUrl);

                                final updatedUser = await philgoApiUserUpdate({
                                  'photo_url': '',
                                });

                                // Evict old photo from cache after deletion
                                // 삭제 후 이전 사진 캐시 제거
                                if (oldPhotoUrl != null &&
                                    oldPhotoUrl.isNotEmpty) {
                                  await CachedNetworkImage.evictFromCache(
                                    oldPhotoUrl,
                                  );
                                }

                                if (context.mounted) {
                                  PhilgoState.of(context).setUser(updatedUser);
                                  showComicSuccessSnackBar(
                                    context,
                                    T.profilePhotoDeleted,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showComicErrorSnackBar(
                                    context,
                                    '${T.failedToDeletePhoto}: $e',
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  /// [2. Basic Info Section] - 기본 정보 섹션
                  _buildSection(
                    title: T.basicInfo,
                    icon: FontAwesomeIcons.user,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Nickname field
                        _buildFieldLabel(
                          context,
                          T.nickname,
                          FontAwesomeIcons.at,
                        ),
                        const SizedBox(height: 8),
                        ComicTextFormField(
                          controller: _nicknameController,
                          enabled: user.nickname.isEmpty,
                          hintText: T.nicknameHint,
                        ),
                        const SizedBox(height: 20),

                        /// Full name field
                        _buildFieldLabel(
                          context,
                          T.fullName,
                          FontAwesomeIcons.idCard,
                        ),
                        const SizedBox(height: 8),
                        ComicTextFormField(
                          controller: _nameController,
                          hintText: T.fullNameHint,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0),

                  /// [3. Personal Info Section] - 개인 정보 섹션
                  _buildSection(
                    title: T.personalInfo,
                    icon: FontAwesomeIcons.addressCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Birth Date Field
                        _buildFieldLabel(
                          context,
                          T.birthDate,
                          FontAwesomeIcons.cakeCandles,
                        ),
                        const SizedBox(height: 8),
                        DateSelector(
                          date: birthDate,
                          padding: EdgeInsets.zero,
                          label: null,
                          yearHint: T.year,
                          monthHint: T.month,
                          dayHint: T.day,
                          yearUnit: T.yearUnit,
                          monthUnit: T.monthUnit,
                          dayUnit: T.dayUnit,
                          selectYearAndMonthFirstMessage:
                              T.selectYearAndMonthFirst,
                          selectYearFirstMessage: T.selectYearFirst,
                          selectMonthFirstMessage: T.selectMonthFirst,
                          onChange: (date) {
                            birthDate = date;
                          },
                        ),
                        const SizedBox(height: 24),

                        /// Gender Selection
                        _buildFieldLabel(
                          context,
                          T.gender,
                          FontAwesomeIcons.venusMars,
                        ),
                        const SizedBox(height: 12),
                        RadioGroup<String>(
                          groupValue: gender,
                          onChanged: (String? value) {
                            setState(() {
                              gender = value;
                            });
                          },
                          child: Row(
                            children: [
                              _buildGenderOption(
                                context,
                                value: "M",
                                label: T.male,
                                icon: FontAwesomeIcons.mars,
                              ),
                              const SizedBox(width: 12),
                              _buildGenderOption(
                                context,
                                value: "F",
                                label: T.female,
                                icon: FontAwesomeIcons.venus,
                              ),
                              const SizedBox(width: 12),
                              _buildGenderOption(
                                context,
                                value: "N",
                                label: T.preferNotToSay,
                                icon: FontAwesomeIcons.genderless,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),

                  /// [4. Save Button] - 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ComicPrimaryButton(
                      onPressed: isLoading ? null : onProfileSubmit,
                      rounded: ComicButtonRounded.full,
                      padding: ComicButtonPadding.large,
                      textSize: ComicButtonTextSize.large,
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  scheme.onPrimary,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.floppyDisk,
                                  size: 18,
                                  color: scheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  T.save,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
          );
        },
      ),
    );
  }

  /// Builds a section container with header (menu.home.dart style)
  ///
  /// Uses indicator bar + title header and surfaceContainerLowest background
  /// with outlineVariant border (matching MenuGridSection design)
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
        /// Section header - Indicator bar + title (menu.home.dart style)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              /// Section indicator bar
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              /// Section icon
              FaIcon(
                icon,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),

              /// Section title
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

        /// Section content container (menu.home.dart style)
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

  /// Builds a field label widget with an icon
  Widget _buildFieldLabel(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        FaIcon(
          icon,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
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

  /// Builds a gender option widget for the radio group
  Widget _buildGenderOption(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSelected = gender == value;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<String>(value: value),
            ),
            const SizedBox(width: 4),
            FaIcon(
              icon,
              size: 14,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? scheme.primary : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Updates user profile information via API
  Future<void> onProfileSubmit() async {
    if (_nicknameController.text.trim().isEmpty) {
      showComicErrorSnackBar(context, T.nicknameRequired);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = <String, dynamic>{};

      if (PhilgoState.of(context).user!.nickname.isEmpty) {
        data['nickname'] = _nicknameController.text.trim();
      }

      data['name'] = _nameController.text.trim();

      if (gender != null) {
        data['gender'] = gender;
      }

      if (birthDate != 0) {
        data['birth_year'] = birthDate ~/ 10000;
        data['birth_month'] = (birthDate ~/ 100) % 100;
        data['birth_day'] = birthDate % 100;
      }

      final user = await philgoApiUserUpdate(data);
      if (mounted) {
        PhilgoState.of(context).setUser(user);
      }

      if (mounted) {
        showComicSuccessSnackBar(context, T.profileUpdateSuccess);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
