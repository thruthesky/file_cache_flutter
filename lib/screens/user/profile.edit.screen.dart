import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo/widgets/user/user_ready.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';
import 'package:philgo/widgets/theme/comic_snackbar.dart';

class ProfileEditScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/screen-name/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName.replaceFirst(':id'));
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
  bool isLoading = false; // 로딩 상태 관리

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
          child: Container(height: 2, color: scheme.outline),
        ),
      ),
      body: UserReady(
        init: (context, user) async {
          _nicknameController.text = user.nickname;
          _nameController.text = user.name;
          gender = user.gender;
          birthDate = user.birthDate;
          // log('date: $birthDate');
          setState(() {});
        },
        builder: (context, user) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),

                /// Profile Photo Section
                FileUpload(
                  deleteFile: user.photoUrl,
                  file: true,
                  video: true,
                  onUploaded: (url) async {
                    log('uploaded file url: $url');
                    final updatedUser = await philgoApiUserUpdate({
                      'photo_url': url,
                    });
                    if (context.mounted) {
                      // Update the global app state
                      AppState.of(context).setUser(updatedUser);
                      // Comic Design: Use Comic SnackBar for consistent styling
                      showComicSuccessSnackBar(
                        context,
                        'Profile photo updated successfully',
                      );
                    }
                  },
                  onBeforeUpload: () {
                    log('before upload');
                  },
                  onCancelled: () {
                    log('upload cancelled');
                  },
                  child: UserAvatarWithUploadIcon(
                    size: 125,
                    user: user,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16.0,
                    ),
                    alignment: Alignment.center,
                    onTapDelete: () async {
                      try {
                        await philgoApiFileDelete(login.photoUrl);
                        final updatedUser = await philgoApiUserUpdate({
                          'photo_url': '',
                        });
                        if (context.mounted) {
                          AppState.of(context).setUser(updatedUser);
                          // Comic Design: Use Comic SnackBar for consistent styling
                          showComicSuccessSnackBar(
                            context,
                            'Profile photo deleted',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for consistent styling
                          showComicErrorSnackBar(
                            context,
                            'Failed to delete photo: $e',
                          );
                        }
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),

                /// Nickname Section - Comic Card
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Comic Design: Use ComicTextFormField for consistent styling
                      Text(
                        T.nickname,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      ComicTextFormField(
                        controller: _nicknameController,
                        enabled: user.nickname.isEmpty,
                        hintText: T.nicknameHint,
                      ),
                      SizedBox(height: 16),

                      // Comic Design: Use ComicTextFormField for consistent styling
                      Text(
                        T.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      ComicTextFormField(
                        controller: _nameController,
                        hintText: T.fullNameHint,
                      ),

                      SizedBox(height: 24),

                      /// Birth Date Field
                      Text(
                        T.birthDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
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
                      SizedBox(height: 24),

                      /// Gender Selection
                      Text(
                        T.gender,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      RadioGroup<String>(
                        groupValue: gender,
                        onChanged: (String? value) {
                          setState(() {
                            gender = value;
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Radio<String>(value: "M"),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  T.male,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Radio<String>(value: "F"),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  T.female,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Radio<String>(value: "N"),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  T.preferNotToSay,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                /// Save Button - Comic Design: Use ComicButton for custom styling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ComicButton(
                      onPressed: isLoading ? null : onProfileSubmit,
                      rounded: ComicButtonRounded.normal,
                      padding: ComicButtonPadding.large,
                      textSize: ComicButtonTextSize.large,
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(width: 8),
                                Text(
                                  T.save,
                                  style: TextStyle(color: scheme.primary),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 사용자 프로필 정보를 업데이트하는 메서드
  /// user.update API를 호출하여 닉네임, 이름, 생년월일, 성별을 업데이트
  Future<void> onProfileSubmit() async {
    // 입력값 검증
    if (_nicknameController.text.trim().isEmpty) {
      // Comic Design: Use Comic SnackBar for consistent styling
      showComicErrorSnackBar(context, T.nicknameRequired);
      return;
    }

    // 로딩 시작
    setState(() {
      isLoading = true;
    });
    try {
      // API 호출을 위한 데이터 준비
      final data = <String, dynamic>{};

      // 닉네임: 기존 닉네임이 없을 때만 업데이트 (첫 설정 시에만)
      if (login.nickname.isEmpty) {
        data['nickname'] = _nicknameController.text.trim();
      }

      // 이름이 입력되었으면 추가
      data['name'] = _nameController.text.trim();

      // 성별 정보 추가
      if (gender != null) {
        data['gender'] = gender;
      }

      // 생년월일 정보 추가
      if (birthDate != 0) {
        data['birth_year'] = birthDate ~/ 10000;
        data['birth_month'] = (birthDate ~/ 100) % 100;
        data['birth_day'] = birthDate % 100;
      }

      // user.update API 호출
      final user = await philgoApiUserUpdate(data);
      if (mounted) {
        AppState.of(context).setUser(user);
      }

      // 성공 메시지 표시
      if (mounted) {
        // Comic Design: Use Comic SnackBar for consistent styling
        showComicSuccessSnackBar(context, T.profileUpdateSuccess);
      }
    } finally {
      // 로딩 종료
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
