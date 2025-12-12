/// Gets the file extension from a URL
///
/// Extracts the file extension from a URL, removing query strings and hash fragments.
/// Returns the extension in lowercase without the dot.
///
/// Example:
/// ```dart
/// getFileExtension('https://example.com/image.jpg?size=large') // Returns: 'jpg'
/// getFileExtension('https://example.com/video.mp4#t=10') // Returns: 'mp4'
/// getFileExtension('https://example.com/file') // Returns: ''
/// ```
String getFileExtension(String url) {
  // Regular expression to match file extension before query string or hash
  // Pattern: \.([^.\/\?#]+)(?:[\?#]|$)
  // - \. matches the dot before extension
  // - ([^.\/\?#]+) captures the extension (any chars except . / ? #)
  // - (?:[\?#]|$) ensures we stop at query string, hash, or end of string
  final RegExp regex = RegExp(r'\.([^.\/\?#]+)(?:[\?#]|$)');
  final Match? match = regex.firstMatch(url);

  if (match != null && match.groupCount >= 1) {
    return match.group(1)!.toLowerCase();
  }

  return '';
}
