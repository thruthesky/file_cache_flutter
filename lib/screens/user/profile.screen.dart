import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/widgets/user/user_ready.dart';
import 'package:v6_apps/v6_apps.dart';
import 'package:philgo/globals.dart';

class ProfileScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/screen-name/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName.replaceFirst(':id'));
  static const String routeName = '/profile';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(T.editProfile),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: UserReady(
        init: (context, user) async {
          _nicknameController.text = user.nickname;
          _nameController.text = user.name;
          gender = user.gender;
          birthDate = user.birthDate;
          log('date: $birthDate');
          setState(() {});
        },
        builder: (context, user) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              FileUpload(
                deleteFile: user.photoUrl,
                file: true,
                video: true,
                onUploaded: (url) async {
                  log('uploaded file url: $url');
                  final user = await philgoApiUserUpdate({'photo_url': url});
                  if (context.mounted) {
                    AppState.of(context).setUser(user);
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
                    } finally {
                      await philgoApiUserUpdate({'photo_url': ''});
                      if (context.mounted) {
                        AppState.of(context).deletePhotoUrl();
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  T.tapPhotoChange,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              SizedBox(height: 16),
              TextFieldSet(
                label: T.nickname,
                hintText: T.nicknameHint,
                bottomHint: T.nicknameDisplayHint,
                prefixFaIconData: FontAwesomeIcons.tag,
                controller: _nicknameController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4.0,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 24,
                endIndent: 24,
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
                child: Text(
                  T.profileRequiredFieldsNotice,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              SizedBox(height: 8),
              TextFieldSet(
                label: T.fullName,
                hintText: T.fullNameHint,
                bottomHint: T.enterRealNameHint,
                prefixFaIconData: FontAwesomeIcons.user,
                controller: _nameController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8.0,
                ),
              ),
              DateSelector(
                date: birthDate,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8.0,
                ),
                bottomHint: T.selectBirthDateHint,
                label: T.birthDate,
                yearHint: T.year,
                monthHint: T.month,
                dayHint: T.day,
                yearUnit: T.yearUnit,
                monthUnit: T.monthUnit,
                dayUnit: T.dayUnit,
                selectYearAndMonthFirstMessage: T.selectYearAndMonthFirst,
                selectYearFirstMessage: T.selectYearFirst,
                selectMonthFirstMessage: T.selectMonthFirst,
                onChange: (date) {
                  birthDate = date;
                },
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.gender,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
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
                              SizedBox(width: 8),
                              FaIcon(
                                FontAwesomeIcons.mars,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              SizedBox(width: 4),
                              Text(
                                T.male,
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
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
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.venus, size: 16),
                              SizedBox(width: 4),
                              Text(
                                T.female,
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // TODO: Change the value of 'N' to whatever value must be sent via the API in order to save the gender as 'Prefer not to say'
                          // I added this option because I saw in the new.philgo.com website that the 'Edit Profile' page had this option
                          Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Radio<String>(value: "N"),
                              ),
                              SizedBox(width: 8),
                              Text(
                                T.preferNotToSay,
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
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
              SubmitButton.icon(
                context: context,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                alignment: Alignment.center,
                onPressed: isLoading ? null : onProfileSubmit,
                isLoading: isLoading,
                icon: FaIcon(FontAwesomeIcons.floppyDisk),
                label: Text(T.save),
              ),
            ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(T.nicknameRequired),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // 로딩 시작
    setState(() {
      isLoading = true;
    });
    try {
      // API 호출을 위한 데이터 준비
      final data = <String, dynamic>{};

      // 닉네임은 필수
      data['nickname'] = _nicknameController.text.trim();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T.profileUpdateSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
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
