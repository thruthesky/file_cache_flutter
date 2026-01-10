# 구인 게시글 양식 작성 계획

> **참고 문서**: [api-spec-post-job-hiring.md](../.claude/skills/philgo-skill/references/api/api-spec-post-job-hiring.md)

---

## 개요

wanted 게시판에서 "구인(hiring)"과 "구직(looking)" 카테고리를 분리하고, 구인 글 작성 시 별도의 양식을 제공합니다.

---

## 요구사항

| 구분 | 양식 | 비고 |
|------|------|------|
| **구인 (hiring)** | 별도 폼 (9개 필드) | 모든 필드 필수 |
| **구직 (looking)** | 기존 일반 폼 (제목 + 내용) | 변경 없음 |

---

## 필드 매핑 (API 스펙 기준)

> **중요**: 앱에서는 모든 항목이 필수입니다.

| 순서 | 필드명 | DB 컬럼 | Post 모델 | 타입 | 앱 필수 |
|:----:|--------|---------|-----------|------|:-------:|
| 1 | 제목 | subject | subject | string | ✅ |
| 2 | 회사 이름 | varchar_4 | varchar4 | string | ✅ |
| 3 | 회사 소개 | text_1 | text1 | text | ✅ |
| 4 | 업무 범위 | varchar_9 | varchar9 | string | ✅ |
| 5 | 주소 | varchar_5 | varchar5 | string | ✅ |
| 6 | 전화번호 | varchar_6 | varchar6 | string | ✅ |
| 7 | 이메일 | varchar_8 | varchar8 | string | ✅ |
| 8 | 급여 | int_1 | int1 | int | ✅ |
| 9 | 근무제 | varchar_7 | varchar7 | string | ✅ |

---

## 카테고리 구조

| 항목 | 값 | 설명 |
|------|-----|------|
| 게시판 ID | `wanted` | POST_ID_JOB |
| 구인 카테고리 | `hiring` | 회사가 직원 채용 |
| 구직 카테고리 | `looking` | 개인이 일자리 탐색 |

---

## 구현 단계

### 1단계: 서브카테고리 추가

**파일**: `packages/philgo_api/lib/src/philgo.category.dart` (라인 134-135)

```dart
// 변경 전 (라인 134-135)
/// wanted (구직)
'wanted': [],

// 변경 후
/// wanted (구인구직) - hiring: 구인, looking: 구직
'wanted': ['hiring', 'looking'],
```

---

### 2단계: 구인 전용 폼 위젯 생성

**신규 파일**: `lib/screens/post/widgets/wanted_hiring_form.dart`

#### 2-1. 위젯 구조

```dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 구인(hiring) 카테고리 전용 글쓰기 폼
///
/// wanted 게시판의 hiring 카테고리에서만 사용되는 특수 폼입니다.
/// 일반 PostCreateForm과 달리 구인 정보에 필요한 필드들을 개별적으로 입력받습니다.
///
/// 필드 목록 (모두 필수):
/// - 제목 (subject)
/// - 회사 이름 (varchar_4)
/// - 회사 소개 (text_1)
/// - 업무 범위 (varchar_9)
/// - 주소 (varchar_5)
/// - 전화번호 (varchar_6)
/// - 이메일 (varchar_8)
/// - 급여 (int_1)
/// - 근무제 (varchar_7)
class WantedHiringForm extends StatefulWidget {
  const WantedHiringForm({
    super.key,
    this.onSubmitted,
    this.onLoadingChanged,
    this.onUploadingChanged,
    this.showSubmitButton = true,
    this.padding,
  });

  /// 제출 성공 시 콜백
  final void Function(Post createdPost)? onSubmitted;

  /// 로딩 상태 변경 시 콜백
  final void Function(bool isLoading)? onLoadingChanged;

  /// 파일 업로드 상태 변경 시 콜백
  final void Function(bool isUploading)? onUploadingChanged;

  /// 제출 버튼 표시 여부
  final bool showSubmitButton;

  /// 폼 전체 패딩
  final EdgeInsetsGeometry? padding;

  @override
  State<WantedHiringForm> createState() => WantedHiringFormState();
}
```

#### 2-2. State 클래스 구조

```dart
class WantedHiringFormState extends State<WantedHiringForm> {
  // 폼 유효성 검사 키
  final _formKey = GlobalKey<FormState>();

  // 텍스트 입력 컨트롤러 (9개 필드)
  final _subjectController = TextEditingController();      // 제목
  final _companyNameController = TextEditingController();  // 회사 이름 (varchar_4)
  final _companyIntroController = TextEditingController(); // 회사 소개 (text_1)
  final _workRangeController = TextEditingController();    // 업무 범위 (varchar_9)
  final _addressController = TextEditingController();      // 주소 (varchar_5)
  final _phoneController = TextEditingController();        // 전화번호 (varchar_6)
  final _emailController = TextEditingController();        // 이메일 (varchar_8)
  final _salaryController = TextEditingController();       // 급여 (int_1)
  final _workTypeController = TextEditingController();     // 근무제 (varchar_7)

  // 로딩 상태
  bool _isLoading = false;

  // 파일 업로드 상태
  int _uploadingCount = 0;

  // 업로드된 파일 URL 목록
  final List<String> _urls = [];

  /// 현재 로딩 중인지 여부
  bool get isLoading => _isLoading;

  /// 현재 파일 업로드 중인지 여부
  bool get isUploading => _uploadingCount > 0;

  @override
  void dispose() {
    _subjectController.dispose();
    _companyNameController.dispose();
    _companyIntroController.dispose();
    _workRangeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _workTypeController.dispose();
    super.dispose();
  }
```

#### 2-3. submit() 메서드

```dart
  /// 폼 제출
  ///
  /// 외부에서 GlobalKey를 통해 호출 가능:
  /// ```dart
  /// formKey.currentState?.submit();
  /// ```
  Future<bool> submit() async {
    // 업로드 진행 중이면 차단
    if (_uploadingCount > 0) {
      showSafeErrorDialog('이미지 업로드 중입니다. 잠시 후 다시 시도해주세요.');
      return false;
    }

    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);

    try {
      log('구인 글 작성 시작', name: 'WantedHiringForm');

      // 급여를 int로 변환
      final salary = int.tryParse(_salaryController.text.trim()) ?? 0;

      // API 호출하여 글 작성
      final created = await createPost({
        'post_id': 'wanted',
        'category': 'hiring',
        'subject': _subjectController.text.trim(),
        // 구인 필드들 (모두 필수)
        'varchar_4': _companyNameController.text.trim(),  // 회사 이름
        'text_1': _companyIntroController.text.trim(),    // 회사 소개
        'varchar_9': _workRangeController.text.trim(),    // 업무 범위
        'varchar_5': _addressController.text.trim(),      // 주소
        'varchar_6': _phoneController.text.trim(),        // 전화번호
        'varchar_8': _emailController.text.trim(),        // 이메일
        'int_1': salary,                                   // 급여
        'varchar_7': _workTypeController.text.trim(),     // 근무제
        'files': _urls,
      });

      log('구인 글 작성 성공 - idx: ${created.idx}', name: 'WantedHiringForm');

      // 성공 콜백 호출
      widget.onSubmitted?.call(created);
      return true;
    } catch (e) {
      log('구인 글 작성 실패: $e', name: 'WantedHiringForm', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }
```

#### 2-4. 필드 빌드 메서드

```dart
  /// 텍스트 입력 필드 빌드 (공통)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validationMessage,
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 (필수 표시 포함)
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 입력 필드
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surface,
            // Comic Design: 2.0px 테두리
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ],
    );
  }
```

#### 2-5. build() 메서드

```dart
  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);

    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const SizedBox(height: 16),

          // 1. 제목
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _subjectController,
              label: '제목',
              hint: '구인 글 제목을 입력하세요',
              validationMessage: '제목을 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 2. 회사 이름
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _companyNameController,
              label: '회사 이름',
              hint: '채용 회사명을 입력하세요',
              validationMessage: '회사 이름을 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 3. 회사 소개
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _companyIntroController,
              label: '회사 소개',
              hint: '회사 소개를 입력하세요 (구인 정보 제외)',
              validationMessage: '회사 소개를 입력해주세요',
              maxLines: 4,
              minLines: 3,
            ),
          ),
          const SizedBox(height: 16),

          // 4. 업무 범위
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _workRangeController,
              label: '업무 범위',
              hint: '예: IT, 마케팅, 영업',
              validationMessage: '업무 범위를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 5. 주소
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _addressController,
              label: '필리핀 전체 주소',
              hint: '예: 123 Sample St., Makati City, Philippines',
              validationMessage: '주소를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 6. 전화번호
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _phoneController,
              label: '필리핀 전화번호',
              hint: '예: 09171234567',
              validationMessage: '전화번호를 입력해주세요',
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),

          // 7. 이메일
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _emailController,
              label: '이메일 주소',
              hint: '예: hr@company.com',
              validationMessage: '이메일을 입력해주세요',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),

          // 8. 급여
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _salaryController,
              label: '급여 (페소)',
              hint: '예: 50000',
              validationMessage: '급여를 입력해주세요',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 16),

          // 9. 근무제
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _workTypeController,
              label: '근무제',
              hint: '예: 주 5일, 월-금',
              validationMessage: '근무제를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 액션 바 (파일 업로드 + 제출 버튼)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildActionBar(context),
          ),

          // 업로드 미리보기
          if (_urls.isNotEmpty || _uploadingCount > 0) ...[
            const SizedBox(height: 16),
            Padding(
              padding: padding,
              child: _buildUploadPreview(context),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
```

---

### 3단계: PostCreateScreen 분기 처리

**파일**: `lib/screens/post/post.create.screen.dart`

#### 3-1. import 추가 (라인 1-6 근처)

```dart
import 'package:philgo/screens/post/widgets/wanted_hiring_form.dart';
```

#### 3-2. formKey 타입 변경 (라인 80)

```dart
// 변경 전
final formKey = GlobalKey<PostCreateFormState>();

// 변경 후 - 두 폼 타입을 모두 지원하도록 변경
GlobalKey<PostCreateFormState>? _postFormKey;
GlobalKey<WantedHiringFormState>? _hiringFormKey;
```

#### 3-3. body 부분 분기 처리 (라인 334-376)

```dart
/// 구인 폼인지 확인
bool get _isHiringForm =>
    widget.postId == 'wanted' && _selectedCategory == 'hiring';

/// PostCreateForm 또는 WantedHiringForm 분기 처리
body: _isHiringForm
    ? WantedHiringForm(
        key: _hiringFormKey ??= GlobalKey<WantedHiringFormState>(),
        onLoadingChanged: (loading) {
          setState(() {
            isLoading = loading;
          });
        },
        onUploadingChanged: (uploading) {
          setState(() {
            isUploading = uploading;
          });
        },
        onSubmitted: (post) {
          Navigator.pop(context);
          PostViewScreen.push(context, post);
          widget.onSubmitted?.call(post);
        },
        showSubmitButton: true,
      )
    : PostCreateForm(
        key: _postFormKey ??= GlobalKey<PostCreateFormState>(),
        postId: widget.postId,
        category: _selectedCategory,
        initialContent: widget.content,
        initialFiles: widget.xFiles,
        showSubmitButton: true,
        onLoadingChanged: (loading) {
          setState(() {
            isLoading = loading;
          });
        },
        onUploadingChanged: (uploading) {
          setState(() {
            isUploading = uploading;
          });
        },
        onSubmitted: (post) {
          Navigator.pop(context);
          PostViewScreen.push(context, post);
          widget.onSubmitted?.call(post);
        },
      ),
```

#### 3-4. AppBar 제출 버튼 분기 처리 (라인 302-307)

```dart
onPressed: (isLoading || isUploading)
    ? null
    : () async {
        if (_isHiringForm) {
          await _hiringFormKey?.currentState?.submit();
        } else {
          await _postFormKey?.currentState?.submit();
        }
      },
```

---

### 4단계: i18n 번역 추가

**파일**: `lib/l10n/app_ko.arb`

```json
{
  "wantedHiring": "구인",
  "wantedLooking": "구직",
  "wantedCompanyName": "회사 이름",
  "wantedCompanyNameHint": "채용 회사명을 입력하세요",
  "wantedCompanyNameRequired": "회사 이름을 입력해주세요",
  "wantedCompanyIntro": "회사 소개",
  "wantedCompanyIntroHint": "회사 소개를 입력하세요 (구인 정보 제외)",
  "wantedCompanyIntroRequired": "회사 소개를 입력해주세요",
  "wantedWorkRange": "업무 범위",
  "wantedWorkRangeHint": "예: IT, 마케팅, 영업",
  "wantedWorkRangeRequired": "업무 범위를 입력해주세요",
  "wantedAddress": "필리핀 전체 주소",
  "wantedAddressHint": "예: 123 Sample St., Makati City, Philippines",
  "wantedAddressRequired": "주소를 입력해주세요",
  "wantedPhone": "필리핀 전화번호",
  "wantedPhoneHint": "예: 09171234567",
  "wantedPhoneRequired": "전화번호를 입력해주세요",
  "wantedEmail": "이메일 주소",
  "wantedEmailHint": "예: hr@company.com",
  "wantedEmailRequired": "이메일을 입력해주세요",
  "wantedSalary": "급여 (페소)",
  "wantedSalaryHint": "예: 50000",
  "wantedSalaryRequired": "급여를 입력해주세요",
  "wantedWorkType": "근무제",
  "wantedWorkTypeHint": "예: 주 5일, 월-금",
  "wantedWorkTypeRequired": "근무제를 입력해주세요"
}
```

**파일**: `lib/l10n/app_en.arb`

```json
{
  "wantedHiring": "Hiring",
  "wantedLooking": "Looking for Job",
  "wantedCompanyName": "Company Name",
  "wantedCompanyNameHint": "Enter the company name",
  "wantedCompanyNameRequired": "Please enter the company name",
  "wantedCompanyIntro": "Company Introduction",
  "wantedCompanyIntroHint": "Enter company introduction (excluding job info)",
  "wantedCompanyIntroRequired": "Please enter the company introduction",
  "wantedWorkRange": "Work Range",
  "wantedWorkRangeHint": "e.g., IT, Marketing, Sales",
  "wantedWorkRangeRequired": "Please enter the work range",
  "wantedAddress": "Full Address in Philippines",
  "wantedAddressHint": "e.g., 123 Sample St., Makati City, Philippines",
  "wantedAddressRequired": "Please enter the address",
  "wantedPhone": "Phone Number",
  "wantedPhoneHint": "e.g., 09171234567",
  "wantedPhoneRequired": "Please enter the phone number",
  "wantedEmail": "Email Address",
  "wantedEmailHint": "e.g., hr@company.com",
  "wantedEmailRequired": "Please enter the email address",
  "wantedSalary": "Salary (Peso)",
  "wantedSalaryHint": "e.g., 50000",
  "wantedSalaryRequired": "Please enter the salary",
  "wantedWorkType": "Work Type",
  "wantedWorkTypeHint": "e.g., 5 days a week, Mon-Fri",
  "wantedWorkTypeRequired": "Please enter the work type"
}
```

---

### 5단계: 검증

```bash
flutter analyze
```

---

## 수정할 파일 목록

| 순서 | 파일 | 작업 내용 |
|:----:|------|----------|
| 1 | `packages/philgo_api/lib/src/philgo.category.dart` | 서브카테고리 추가 |
| 2 | `lib/screens/post/widgets/wanted_hiring_form.dart` | 신규 생성 - 구인 폼 위젯 |
| 3 | `lib/screens/post/post.create.screen.dart` | 분기 처리 추가 |
| 4 | `lib/l10n/app_ko.arb` | 한국어 번역 추가 |
| 5 | `lib/l10n/app_en.arb` | 영어 번역 추가 |

---

## API 호출 예시

```dart
await createPost({
  'post_id': 'wanted',
  'category': 'hiring',
  'subject': '개발자 모집',
  // 모든 필드 필수
  'varchar_4': 'ABC 회사',           // 회사 이름
  'text_1': '우리 회사 소개...',       // 회사 소개
  'varchar_9': 'IT, 마케팅',          // 업무 범위
  'varchar_5': 'Makati City, PH',    // 주소
  'varchar_6': '09171234567',        // 전화번호
  'varchar_8': 'hr@company.com',     // 이메일
  'int_1': 50000,                    // 급여
  'varchar_7': '주 5일',              // 근무제
  'files': [],
});
```

---

## 검증 방법

1. 앱에서 구인/구직 게시판 진입
2. 글쓰기 버튼 클릭
3. 카테고리 드롭다운에서 "구인" 또는 "구직" 선택 확인
4. **"구인" 선택 시**: WantedHiringForm (9개 필드) 표시 확인
5. **"구직" 선택 시**: 기존 PostCreateForm (제목 + 내용) 표시 확인
6. 구인 폼에서 모든 필드 필수 검증 확인
7. 빈 필드가 있으면 제출 불가 확인
8. 글 작성 후 저장 및 조회 확인
9. 저장된 글에서 필드값들이 Markdown으로 변환되어 표시되는지 확인

---

## 버전 히스토리

| 날짜 | 변경 내용 |
|------|----------|
| 2026-01-10 | 초기 계획 작성 - 구인 글 양식 분리 계획 |
| 2026-01-10 | 모든 필드 필수로 변경, 상세 코드 추가 |
