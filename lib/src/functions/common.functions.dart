/// Cut the text with the length and padding.
///
/// [text] text to cut
/// [length] length to cut from the beginning of the text. If the text is shorter
/// than the length, then return the original text. If the text is longer than
/// the length, then return the text with the padding.
/// [pad] string to add at the end of the text if the text is longer than the length.
/// [defaultValue] default value to return if text is null or empty.
///
/// Returns text with the padding if the text is longer than the length.
///
/// Example:
/// ```dart
/// cut('Hello, World!', 5, pad: '...'); // Hello...
/// cut(user.name, 10, pad: '');
/// ```
String cut(
  String? text,
  int length, {
  String pad = '...',
  String defaultValue = '...',
}) {
  if (text == null || text.isEmpty) return defaultValue;
  if (text.length > length) {
    return text.substring(0, length) + pad;
  }
  return text;
}
