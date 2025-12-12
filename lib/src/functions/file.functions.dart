/// File preview type enumeration
/// Used to determine how to render the preview based on file type
enum UploadFileType {
  /// Image files (jpg, jpeg, png, gif, webp, bmp)
  image,

  /// Video files (mp4, mov, avi, mkv, webm, flv)
  video,

  /// Other files (pdf, doc, txt, etc.)
  file,
}

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

/// Detects the file type based on the URL extension
///
/// Returns [FileType] to determine the appropriate file handling or rendering.
/// Supports common image, video, and file extensions.
///
/// Example:
/// ```dart
/// detectFileType('https://example.com/photo.jpg') // Returns: FileType.image
/// detectFileType('https://example.com/video.mp4') // Returns: FileType.video
/// detectFileType('https://example.com/document.pdf') // Returns: FileType.file
/// ```
UploadFileType detectUploadFileType(String url) {
  final extension = getFileExtension(url);

  // Image extensions
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  if (imageExtensions.contains(extension)) {
    return UploadFileType.image;
  }

  // Video extensions
  const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv'];
  if (videoExtensions.contains(extension)) {
    return UploadFileType.video;
  }

  // Default to file for everything else
  return UploadFileType.file;
}
