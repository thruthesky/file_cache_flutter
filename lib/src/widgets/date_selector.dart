import 'package:flutter/material.dart';

/// DateSelector - 연도, 월, 일 선택 위젯
///
/// ## 개요
/// 연도, 월, 일을 드롭다운으로 선택할 수 있는 날짜 선택 위젯입니다.
/// 선택된 날짜는 YYYYMMDD 형식의 8자리 정수로 반환됩니다.
///
/// ## 주요 기능
/// - 연도: 1945년부터 (현재년도-15)년까지 선택 가능
/// - 월: 1월부터 12월까지 선택
/// - 일: 선택된 월에 따라 자동으로 일수 조정 (28~31일)
/// - 한 줄에 연도, 월, 일 드롭다운 배치
/// - 선택 변경 시 즉시 콜백 호출
///
/// ## 주요 파라미터
/// - [date]: 초기 선택값 (YYYYMMDD 형식의 8자리 정수)
/// - [onChange]: 날짜 변경 시 호출되는 콜백 (YYYYMMDD 형식으로 전달)
/// - [label]: 선택 박스 상단에 표시될 라벨
///
/// ## 사용 예시
/// ```dart
/// DateSelector(
///   date: 19900315,  // 1990년 3월 15일
///   label: '생년월일',
///   onChange: (value) {
///     print('선택된 날짜: $value');  // 예: 19900315
///   },
/// )
/// ```
class DateSelector extends StatefulWidget {
  /// 초기 날짜값 (YYYYMMDD 형식)
  /// 예: 19900315 = 1990년 3월 15일
  final int? date;

  /// 날짜 변경 시 호출되는 콜백
  /// YYYYMMDD 형식의 8자리 정수를 전달
  final void Function(int date)? onChange;

  /// 선택 박스 상단에 표시될 라벨
  final String? label;

  final EdgeInsetsGeometry? padding;

  final String? bottomHint;

  /// 연도 힌트 텍스트 (기본값: '연도')
  final String? yearHint;

  /// 월 힌트 텍스트 (기본값: '월')
  final String? monthHint;

  /// 일 힌트 텍스트 (기본값: '일')
  final String? dayHint;

  /// 연도 단위 텍스트 (기본값: '년')
  final String? yearUnit;

  /// 월 단위 텍스트 (기본값: '월')
  final String? monthUnit;

  /// 일 단위 텍스트 (기본값: '일')
  final String? dayUnit;

  /// 연도와 월 선택 필요 메시지 (기본값: '먼저 연도와 월을 선택해주세요')
  final String? selectYearAndMonthFirstMessage;

  /// 연도 선택 필요 메시지 (기본값: '먼저 연도를 선택해주세요')
  final String? selectYearFirstMessage;

  /// 월 선택 필요 메시지 (기본값: '먼저 월을 선택해주세요')
  final String? selectMonthFirstMessage;

  const DateSelector({
    super.key,
    this.date,
    this.onChange,
    this.label,
    this.padding,
    this.bottomHint,
    this.yearHint,
    this.monthHint,
    this.dayHint,
    this.yearUnit,
    this.monthUnit,
    this.dayUnit,
    this.selectYearAndMonthFirstMessage,
    this.selectYearFirstMessage,
    this.selectMonthFirstMessage,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  // 현재 선택된 연도, 월, 일
  late int? selectedYear;
  late int? selectedMonth;
  late int? selectedDay;

  // 연도 범위 계산
  late final int minYear = 1945;
  late final int maxYear = DateTime.now().year - 15;

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  @override
  void didUpdateWidget(DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _initializeDate();
    }
  }

  /// 초기 날짜값 파싱 및 설정
  void _initializeDate() {
    if (widget.date != null) {
      // YYYYMMDD 형식에서 연도, 월, 일 추출
      final dateString = widget.date.toString().padLeft(8, '0');
      selectedYear = int.tryParse(dateString.substring(0, 4));
      selectedMonth = int.tryParse(dateString.substring(4, 6));
      selectedDay = int.tryParse(dateString.substring(6, 8));

      // 유효성 검증
      if (selectedYear != null &&
          (selectedYear! < minYear || selectedYear! > maxYear)) {
        selectedYear = null;
      }
      if (selectedMonth != null &&
          (selectedMonth! < 1 || selectedMonth! > 12)) {
        selectedMonth = null;
      }
      // Validate day: must be at least 1
      if (selectedDay != null && selectedDay! < 1) {
        selectedDay = null;
      }
      // Further validate day against the max day of the selected month
      if (selectedDay != null &&
          selectedMonth != null &&
          selectedYear != null) {
        final maxDay = _getMaxDayOfMonth(selectedYear!, selectedMonth!);
        if (selectedDay! > maxDay) {
          selectedDay = null;
        }
      }
    } else {
      selectedYear = null;
      selectedMonth = null;
      selectedDay = null;
    }
  }

  /// 선택된 월의 최대 일수 계산
  int _getMaxDayOfMonth(int year, int month) {
    if (month == 2) {
      // 윤년 체크
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      }
      return 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }

  /// 날짜 변경 시 콜백 호출
  void _onDateChanged() {
    if (selectedYear != null && selectedMonth != null && selectedDay != null) {
      // YYYYMMDD 형식으로 변환
      final date = selectedYear! * 10000 + selectedMonth! * 100 + selectedDay!;
      widget.onChange?.call(date);
    }
  }

  /// 월이 변경되었을 때 일수 조정
  void _adjustDayForMonth() {
    if (selectedYear != null && selectedMonth != null && selectedDay != null) {
      final maxDay = _getMaxDayOfMonth(selectedYear!, selectedMonth!);
      if (selectedDay! > maxDay) {
        setState(() {
          selectedDay = maxDay;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨 표시
          if (widget.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.label!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // 연도, 월, 일 선택 드롭다운 (한 줄에 배치)
          Row(
            children: [
              // 연도 선택
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    hint: Text(
                      widget.yearHint ?? '연도',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    items: List.generate(maxYear - minYear + 1, (index) {
                      final year = maxYear - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          '$year${widget.yearUnit ?? '년'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        _adjustDayForMonth();
                      });
                      _onDateChanged();
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 월 선택
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    hint: Text(
                      widget.monthHint ?? '월',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          '$month${widget.monthUnit ?? '월'}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        _adjustDayForMonth();
                      });
                      _onDateChanged();
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 일 선택
              Expanded(
                child: GestureDetector(
                  // 연도나 월이 선택되지 않았을 때 탭 감지하여 경고 메시지 표시
                  onTap: (selectedYear == null || selectedMonth == null)
                      ? () {
                          // 선택되지 않은 항목에 따라 적절한 메시지 생성
                          String message = '';
                          if (selectedYear == null && selectedMonth == null) {
                            message =
                                widget.selectYearAndMonthFirstMessage ??
                                '먼저 연도와 월을 선택해주세요';
                          } else if (selectedYear == null) {
                            message =
                                widget.selectYearFirstMessage ??
                                '먼저 연도를 선택해주세요';
                          } else {
                            message =
                                widget.selectMonthFirstMessage ??
                                '먼저 월을 선택해주세요';
                          }

                          // ScaffoldMessenger로 경고 스낵바 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                message,
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      // 비활성 상태일 때 시각적 피드백을 위한 배경색 변경
                      color: (selectedYear == null || selectedMonth == null)
                          ? colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            )
                          : null,
                    ),
                    child: DropdownButton<int>(
                      value: selectedDay,
                      hint: Text(
                        widget.dayHint ?? '일',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        // 비활성 상태일 때 아이콘 색상도 변경
                        color: (selectedYear == null || selectedMonth == null)
                            ? colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                      items: selectedYear != null && selectedMonth != null
                          ? List.generate(
                              _getMaxDayOfMonth(selectedYear!, selectedMonth!),
                              (index) {
                                final day = index + 1;
                                return DropdownMenuItem(
                                  value: day,
                                  child: Text(
                                    '$day${widget.dayUnit ?? '일'}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                );
                              },
                            )
                          : [],
                      onChanged: selectedYear != null && selectedMonth != null
                          ? (value) {
                              setState(() {
                                selectedDay = value;
                              });
                              _onDateChanged();
                            }
                          : null, // 연도와 월이 선택되지 않으면 비활성화
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.bottomHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.bottomHint!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
