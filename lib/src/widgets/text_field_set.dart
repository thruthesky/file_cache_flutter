import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// TextFieldSet - 통합 텍스트 입력 위젯
///
/// ## 개요
/// 앱 전체에서 일관된 디자인의 텍스트 입력 필드를 제공하는 재사용 가능한 위젯입니다.
/// TextField의 모든 속성과 Padding 속성을 지원하며, 라벨과 아이콘을 포함한 완전한 입력 UI를 구성합니다.
///
/// ## Opinionated Design
///
/// - The border is set to outline-border. And you cannot change it.
///
/// ## 주요 기능
/// - 라벨, 아이콘, 힌트 텍스트가 포함된 완전한 입력 필드 세트
/// - TextField의 모든 기본 속성 지원
/// - 앱 전체에서 통일된 디자인 유지
/// - 커스터마이징 가능한 스타일링
///
/// ## 주요 파라미터
/// - [padding]: 라벨과 텍스트 필드를 포함한 전체 위젯 주변의 패딩
/// - [label]: 텍스트 필드 상단에 표시되는 라벨 텍스트
/// - [icon]: 텍스트 필드 시작 부분에 표시되는 아이콘
/// - [hintText]: 텍스트 필드 내부에 표시되는 힌트 텍스트
/// - [controller]: 텍스트 입력값을 제어하는 TextEditingController
///
/// ## 사용 예시
/// ```dart
/// TextFieldSet(
///   label: '이메일',
///   icon: Icons.email,
///   hintText: 'example@email.com',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
/// )
/// ```
///
/// ## 활용처
/// - 로그인/회원가입 폼
/// - 프로필 편집 화면
/// - 설정 화면의 입력 필드
/// - 검색 바
/// - 댓글 입력 필드
/// - 기타 사용자 입력이 필요한 모든 곳
class TextFieldSet extends StatelessWidget {
  const TextFieldSet({
    super.key,
    this.padding,
    this.label,
    this.icon,
    this.prefixFaIconData,
    this.hintText,
    this.bottomHint,
    this.groupId = EditableText,
    this.controller,
    this.focusNode,
    this.undoController,
    this.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    this.toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    this.selectAllOnFocus,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    @Deprecated(
      'Use `stylusHandwritingEnabled` instead. '
      'This feature was deprecated after v3.27.0-0.2.pre.',
    )
    this.scribbleEnabled = true,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.hintLocales,
  }) : assert(obscuringCharacter.length == 1),
       smartDashesType =
           smartDashesType ??
           (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
       smartQuotesType =
           smartQuotesType ??
           (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
       assert(maxLines == null || maxLines > 0),
       assert(minLines == null || minLines > 0),
       assert(
         (maxLines == null) || (minLines == null) || (maxLines >= minLines),
         "minLines can't be greater than maxLines",
       ),
       assert(
         !expands || (maxLines == null && minLines == null),
         'minLines and maxLines must be null when expands is true.',
       ),
       assert(
         !obscureText || maxLines == 1,
         'Obscured fields cannot be multiline.',
       ),
       assert(
         maxLength == null ||
             maxLength == TextField.noMaxLength ||
             maxLength > 0,
       ),

       /// Assert the following instead of setting it directly to avoid surprising the user by silently changing the value they set.
       assert(
         !identical(textInputAction, TextInputAction.newline) ||
             maxLines == 1 ||
             !identical(keyboardType, TextInputType.text),
         'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
       ),
       keyboardType =
           keyboardType ??
           (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
       enableInteractiveSelection =
           enableInteractiveSelection ?? (!readOnly || !obscureText);

  final EdgeInsetsGeometry? padding;

  final String? label;

  final Widget? icon;
  final IconData? prefixFaIconData;

  final String? hintText;
  final String? bottomHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
      child: Column(
        children: [
          if (label != null)
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                label!,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          TextField(
            readOnly: readOnly,
            controller: controller,
            decoration: _buildDecoration(),
            enabled: enabled,
            onTap: onTap,
          ),
          if (bottomHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  bottomHint!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ///
  InputDecoration _buildDecoration() {
    return (decoration ?? const InputDecoration()).copyWith(
      hintText: hintText,
      border: const OutlineInputBorder(),
      prefixIcon: prefixFaIconData != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: FaIcon(prefixFaIconData, size: 16),
            )
          : icon,
      prefixIconConstraints: const BoxConstraints(minHeight: 12, minWidth: 40),
    );
  }

  /// The configuration for the magnifier of this text field.
  ///
  /// By default, builds a [CupertinoTextMagnifier] on iOS and [TextMagnifier]
  /// on Android, and builds nothing on all other platforms. To suppress the
  /// magnifier, consider passing [TextMagnifierConfiguration.disabled].
  ///
  /// {@macro flutter.widgets.magnifier.intro}
  ///
  /// {@tool dartpad}
  /// This sample demonstrates how to customize the magnifier that this text field uses.
  ///
  /// ** See code in examples/api/lib/widgets/text_magnifier/text_magnifier.0.dart **
  /// {@end-tool}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// {@macro flutter.widgets.editableText.groupId}
  final Object groupId;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// The [focusNode] is a long-lived object that's typically managed by a
  /// [StatefulWidget] parent. See [FocusNode] for more information.
  ///
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  ///
  /// ```dart
  /// FocusScope.of(context).requestFocus(myFocusNode);
  /// ```
  ///
  /// This happens automatically when the widget is tapped.
  ///
  /// To be notified when the widget gains or loses the focus, add a listener
  /// to the [focusNode]:
  ///
  /// ```dart
  /// myFocusNode.addListener(() { print(myFocusNode.hasFocus); });
  /// ```
  ///
  /// If null, this widget will create its own [FocusNode].
  ///
  /// ## Keyboard
  ///
  /// Requesting the focus will typically cause the keyboard to be shown
  /// if it's not showing already.
  ///
  /// On Android, the user can hide the keyboard - without changing the focus -
  /// with the system back button. They can restore the keyboard's visibility
  /// by tapping on a text field. The user might hide the keyboard and
  /// switch to a physical keyboard, or they might just need to get it
  /// out of the way for a moment, to expose something it's
  /// obscuring. In this case requesting the focus again will not
  /// cause the focus to change, and will not make the keyboard visible.
  ///
  /// This widget builds an [EditableText] and will ensure that the keyboard is
  /// showing when it is tapped by calling [EditableTextState.requestKeyboard()].
  final FocusNode? focusNode;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration? decoration;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// {@template flutter.widgets.TextField.textInputAction}
  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  /// {@endtemplate}
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, [TextTheme.bodyLarge] will be used. When the text field is disabled,
  /// [TextTheme.bodyLarge] with an opacity of 0.38 will be used instead.
  ///
  /// If null and [ThemeData.useMaterial3] is false, [TextTheme.titleMedium] will
  /// be used. When the text field is disabled, [TextTheme.titleMedium] with
  /// [ThemeData.disabledColor] will be used instead.
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.material.InputDecorator.textAlignVertical}
  final TextAlignVertical? textAlignVertical;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.obscuringCharacter}
  final String obscuringCharacter;

  /// {@macro flutter.widgets.editableText.obscureText}
  final bool obscureText;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool? autocorrect;

  /// {@macro flutter.services.TextInputConfiguration.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.TextInputConfiguration.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.TextInputConfiguration.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  ///  * [expands], which determines whether the field should fill the height of
  ///    its parent.
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  @Deprecated(
    'Use `contextMenuBuilder` instead. '
    'This feature was deprecated after v3.3.0-0.5.pre.',
  )
  final ToolbarOptions? toolbarOptions;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// If [maxLength] is set to this value, only the "current input length"
  /// part of the character counter is shown.
  static const int noMaxLength = -1;

  /// The maximum number of characters (Unicode grapheme clusters) to allow in
  /// the text field.
  ///
  /// If set, a character counter will be displayed below the
  /// field showing how many characters have been entered. If set to a number
  /// greater than 0, it will also display the maximum number allowed. If set
  /// to [TextField.noMaxLength] then only the current character count is displayed.
  ///
  /// After [maxLength] characters have been input, additional input
  /// is ignored, unless [maxLengthEnforcement] is set to
  /// [MaxLengthEnforcement.none].
  ///
  /// The text field enforces the length with a [LengthLimitingTextInputFormatter],
  /// which is evaluated after the supplied [inputFormatters], if any.
  ///
  /// This value must be either null, [TextField.noMaxLength], or greater than 0.
  /// If null (the default) then there is no limit to the number of characters
  /// that can be entered. If set to [TextField.noMaxLength], then no limit will
  /// be enforced, but the number of characters entered will still be displayed.
  ///
  /// Whitespace characters (e.g. newline, space, tab) are included in the
  /// character count.
  ///
  /// If [maxLengthEnforcement] is [MaxLengthEnforcement.none], then more than
  /// [maxLength] characters may be entered, but the error counter and divider
  /// will switch to the [decoration]'s [InputDecoration.errorStyle] when the
  /// limit is exceeded.
  ///
  /// {@macro flutter.services.lengthLimitingTextInputFormatter.maxLength}
  final int? maxLength;

  /// Determines how the [maxLength] limit should be enforced.
  ///
  /// {@macro flutter.services.textFormatter.effectiveMaxLengthEnforcement}
  ///
  /// {@macro flutter.services.textFormatter.maxLengthEnforcement}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onChanged}
  ///
  /// See also:
  ///
  ///  * [inputFormatters], which are called before [onChanged]
  ///    runs and can validate and change ("format") the input value.
  ///  * [onEditingComplete], [onSubmitted]:
  ///    which are more specialized input change notifications.
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  ///
  /// See also:
  ///
  ///  * [TextInputAction.next] and [TextInputAction.previous], which
  ///    automatically shift the focus to the next/previous focusable item when
  ///    the user is done editing.
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.onAppPrivateCommand}
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

  /// If false the text field is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// If non-null this property overrides the [decoration]'s
  /// [InputDecoration.enabled] property.
  ///
  /// When a text field is disabled, all of its children widgets are also
  /// disabled, including the [InputDecoration.suffixIcon]. If you need to keep
  /// the suffix icon interactive while disabling the text field, consider using
  /// [readOnly] and [enableInteractiveSelection] instead:
  ///
  /// ```dart
  /// TextField(
  ///   enabled: true,
  ///   readOnly: true,
  ///   enableInteractiveSelection: false,
  ///   decoration: InputDecoration(
  ///     suffixIcon: IconButton(
  ///       onPressed: () {
  ///         /// This will work because the TextField is enabled
  ///       },
  ///       icon: const Icon(Icons.edit_outlined),
  ///     ),
  ///   ),
  /// )
  /// ```
  final bool? enabled;

  /// Determines whether this widget ignores pointer events.
  ///
  /// Defaults to null, and when null, does nothing.
  final bool? ignorePointers;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorOpacityAnimates}
  final bool? cursorOpacityAnimates;

  /// The color of the cursor.
  ///
  /// The cursor indicates the current location of text insertion point in
  /// the field.
  ///
  /// If this is null it will default to the ambient
  /// [DefaultSelectionStyle.cursorColor]. If that is null, and the
  /// [ThemeData.platform] is [TargetPlatform.iOS] or [TargetPlatform.macOS]
  /// it will use [CupertinoThemeData.primaryColor]. Otherwise it will use
  /// the value of [ColorScheme.primary] of [ThemeData.colorScheme].
  final Color? cursorColor;

  /// The color of the cursor when the [InputDecorator] is showing an error.
  ///
  /// If this is null it will default to [TextStyle.color] of
  /// [InputDecoration.errorStyle]. If that is null, it will use
  /// [ColorScheme.error] of [ThemeData.colorScheme].
  final Color? cursorErrorColor;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle? selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle? selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectAllOnFocus}
  final bool? selectAllOnFocus;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@template flutter.material.textfield.onTap}
  /// Called for the first tap in a series of taps.
  ///
  /// The text field builds a [GestureDetector] to handle input events like tap,
  /// to trigger focus requests, to move the caret, adjust the selection, etc.
  /// Handling some of those events by wrapping the text field with a competing
  /// GestureDetector is problematic.
  ///
  /// To unconditionally handle taps, without interfering with the text field's
  /// internal gesture detector, provide this callback.
  ///
  /// If the text field is created with [enabled] false, taps will not be
  /// recognized.
  ///
  /// To be notified when the text field gains or loses the focus, provide a
  /// [focusNode] and add a listener to that.
  ///
  /// To listen to arbitrary pointer events without competing with the
  /// text field's internal gesture detector, use a [Listener].
  /// {@endtemplate}
  ///
  /// If [onTapAlwaysCalled] is enabled, this will also be called for consecutive
  /// taps.
  final GestureTapCallback? onTap;

  /// Whether [onTap] should be called for every tap.
  ///
  /// Defaults to false, so [onTap] is only called for each distinct tap. When
  /// enabled, [onTap] is called for every tap including consecutive taps.
  final bool onTapAlwaysCalled;

  /// {@macro flutter.widgets.editableText.onTapOutside}
  ///
  /// {@tool dartpad}
  /// This example shows how to use a `TextFieldTapRegion` to wrap a set of
  /// "spinner" buttons that increment and decrement a value in the [TextField]
  /// without causing the text field to lose keyboard focus.
  ///
  /// This example includes a generic `SpinnerField<T>` class that you can copy
  /// into your own project and customize.
  ///
  /// ** See code in examples/api/lib/widgets/tap_region/text_field_tap_region.0.dart **
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [TapRegion] for how the region group is determined.
  final TapRegionCallback? onTapOutside;

  /// {@macro flutter.widgets.editableText.onTapUpOutside}
  final TapRegionUpCallback? onTapUpOutside;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.error].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If this property is null, [WidgetStateMouseCursor.textable] will be used.
  ///
  /// The [mouseCursor] is the only property of [TextField] that controls the
  /// appearance of the mouse pointer. All other properties related to "cursor"
  /// stand for the text cursor, which is usually a blinking vertical line at
  /// the editing position.
  final MouseCursor? mouseCursor;

  /// Callback that generates a custom [InputDecoration.counter] widget.
  ///
  /// See [InputCounterWidgetBuilder] for an explanation of the passed in
  /// arguments. The returned widget will be placed below the line in place of
  /// the default widget built when [InputDecoration.counterText] is specified.
  ///
  /// The returned widget will be wrapped in a [Semantics] widget for
  /// accessibility, but it also needs to be accessible itself. For example,
  /// if returning a Text widget, set the [Text.semanticsLabel] property.
  ///
  /// {@tool snippet}
  /// ```dart
  /// Widget counter(
  ///   BuildContext context,
  ///   {
  ///     required int currentLength,
  ///     required int? maxLength,
  ///     required bool isFocused,
  ///   }
  /// ) {
  ///   return Text(
  ///     '$currentLength of $maxLength characters',
  ///     semanticsLabel: 'character count',
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// If buildCounter returns null, then no counter and no Semantics widget will
  /// be created at all.
  final InputCounterWidgetBuilder? buildCounter;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.autofillHints}
  /// {@macro flutter.services.AutofillConfiguration.autofillHints}
  final Iterable<String>? autofillHints;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@template flutter.material.textfield.restorationId}
  /// Restoration ID to save and restore the state of the text field.
  ///
  /// If non-null, the text field will persist and restore its current scroll
  /// offset and - if no [controller] has been provided - the content of the
  /// text field. If a [controller] has been provided, it is the responsibility
  /// of the owner of that controller to persist and restore it, e.g. by using
  /// a [RestorableTextEditingController].
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  /// {@endtemplate}
  final String? restorationId;

  /// {@macro flutter.widgets.editableText.scribbleEnabled}
  @Deprecated(
    'Use `stylusHandwritingEnabled` instead. '
    'This feature was deprecated after v3.27.0-0.2.pre.',
  )
  final bool scribbleEnabled;

  /// {@macro flutter.widgets.editableText.stylusHandwritingEnabled}
  final bool stylusHandwritingEnabled;

  /// {@macro flutter.services.TextInputConfiguration.enableIMEPersonalizedLearning}
  final bool enableIMEPersonalizedLearning;

  /// {@macro flutter.widgets.editableText.contentInsertionConfiguration}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  ///  * [BrowserContextMenu], which allows the browser's context menu on web to
  ///    be disabled and Flutter-rendered context menus to appear.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Determine whether this text field can request the primary focus.
  ///
  /// Defaults to true. If false, the text field will not request focus
  /// when tapped, or when its context menu is displayed. If false it will not
  /// be possible to move the focus to the text field with tab key.
  final bool canRequestFocus;

  /// {@macro flutter.widgets.undoHistory.controller}
  final UndoHistoryController? undoController;

  /// {@macro flutter.services.TextInputConfiguration.hintLocales}
  final List<Locale>? hintLocales;

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        SystemContextMenu.isSupported(context)) {
      return SystemContextMenu.editableText(
        editableTextState: editableTextState,
      );
    }
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  /// {@macro flutter.widgets.EditableText.spellCheckConfiguration}
  ///
  /// If [SpellCheckConfiguration.misspelledTextStyle] is not specified in this
  /// configuration, then [materialMisspelledTextStyle] is used by default.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// The [TextStyle] used to indicate misspelled words in the Material style.
  ///
  /// See also:
  ///  * [SpellCheckConfiguration.misspelledTextStyle], the style configured to
  ///    mark misspelled words with.
  ///  * [CupertinoTextField.cupertinoMisspelledTextStyle], the style configured
  ///    to mark misspelled words with in the Cupertino style.
  static const TextStyle materialMisspelledTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.red,
    decorationStyle: TextDecorationStyle.wavy,
  );
}
