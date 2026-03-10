import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/util/util.functions.dart';

FirebaseStorage get storage => FirebaseStorage.instance;

/// Get storage reference for a file path
Reference getStorageRef(String path) {
  return storage.ref(path);
}

/// Get current user's storage folder path
String get userStoragePath {
  if (loginUid() == null) {
    throw Exception('User is not logged in');
  }
  return 'users/${myUid()}';
}

/// Upload image to Firebase Storage
/// Returns the download URL of the uploaded image
/// Supports both File (mobile/desktop) and XFile (web)
Future<String> uploadImage(
  dynamic file, {
  Function(double)? onProgress,
  String? deleteUrl,
}) async {
  // Check if user is logged in
  if (loginUid() == null) {
    throw Exception('User is not logged in');
  }

  String fileName;
  if (file is XFile) {
    fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
  } else if (file is File) {
    fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
  } else {
    throw ArgumentError('File must be either XFile or File type');
  }

  final String filePath = 'users/${myUid()}/$fileName';
  final Reference uploadRef = storage.ref(filePath);

  final UploadTask uploadTask;
  if (file is XFile) {
    // XFile을 지원하는 플랫폼에서는 readAsBytes()를 사용하여 업로드
    // 웹과 모바일 모두에서 XFile을 안전하게 처리
    final bytes = await file.readAsBytes();
    uploadTask = uploadRef.putData(bytes);
  } else if (file is File) {
    // File 객체는 모바일/데스크톱에서 putFile() 메서드 사용
    uploadTask = uploadRef.putFile(file);
  } else {
    throw ArgumentError('Unsupported file type for current platform');
  }

  // Listen to upload progress
  uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
    final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
    debugLog('Upload is ${progress * 100}% done');

    if (onProgress != null) {
      onProgress(progress);
    }

    switch (snapshot.state) {
      case TaskState.paused:
        debugLog('Upload is paused');
        break;
      case TaskState.running:
        debugLog('Upload is running');
        break;
      case TaskState.success:
        debugLog('Upload complete');
        break;
      case TaskState.canceled:
        debugLog('Upload canceled');
        break;
      case TaskState.error:
        debugLog('Upload error');
        break;
    }
  });

  try {
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadURL = await snapshot.ref.getDownloadURL();

    debugLog('File available at: $downloadURL');

    // Delete previous image if deleteUrl is provided
    if (deleteUrl != null && deleteUrl.isNotEmpty) {
      await deleteImage(deleteUrl);
    }

    return downloadURL;
  } catch (e) {
    debugLog('Upload error: $e');
    rethrow;
  }
}

/// Upload multiple images to Firebase Storage
/// Returns a list of download URLs of the uploaded images
Future<List<String>> uploadMultipleImages(
  List<dynamic> files, {
  Function(int index, double progress)? onProgress,
  Function(int totalCompleted, int totalFiles)? onFileCompleted,
  List<String>? deleteUrls,
}) async {
  // Check if user is logged in
  if (loginUid() == null) {
    throw Exception('User is not logged in');
  }

  if (files.isEmpty) {
    return [];
  }

  final List<String> downloadUrls = [];
  int completedFiles = 0;

  // Upload files concurrently but limit concurrency to prevent overwhelming
  final futures = <Future<String>>[];

  for (int i = 0; i < files.length; i++) {
    final file = files[i];
    // final String fileName =
    //     '${DateTime.now().millisecondsSinceEpoch}_${i}_${file.path.split('/').last}';
    // final String filePath = 'users/${myUid()}/$fileName';

    // final Reference uploadRef = storage.ref(filePath);
    // final UploadTask uploadTask = uploadRef.putFile(file);

    String fileName;
    if (file is XFile) {
      fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    } else if (file is File) {
      fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    } else {
      throw ArgumentError('File must be either XFile or File type');
    }

    final String filePath = 'users/${myUid()}/$fileName';
    final Reference uploadRef = storage.ref(filePath);

    final UploadTask uploadTask;
    if (file is XFile) {
      // XFile을 지원하는 플랫폼에서는 readAsBytes()를 사용하여 업로드
      // 웹과 모바일 모두에서 XFile을 안전하게 처리
      final bytes = await file.readAsBytes();
      uploadTask = uploadRef.putData(bytes);
    } else if (file is File) {
      // File 객체는 모바일/데스크톱에서 putFile() 메서드 사용
      uploadTask = uploadRef.putFile(file);
    } else {
      throw ArgumentError('Unsupported file type for current platform');
    }

    // Listen to upload progress for this specific file
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      debugLog('File $i upload is ${progress * 100}% done');

      onProgress?.call(i, progress);

      if (snapshot.state == TaskState.success) {
        completedFiles++;
        if (onFileCompleted != null) {
          onFileCompleted(completedFiles, files.length);
        }
      }
    });

    // Add the upload future to the list
    futures.add(uploadTask.then((snapshot) => snapshot.ref.getDownloadURL()));
  }

  try {
    // Wait for all uploads to complete
    downloadUrls.addAll(await Future.wait(futures));

    debugLog('All files uploaded successfully: ${downloadUrls.length} files');

    // Delete previous images if deleteUrls is provided
    if (deleteUrls != null && deleteUrls.isNotEmpty) {
      for (final url in deleteUrls) {
        if (url.isNotEmpty) {
          await deleteImage(url);
        }
      }
    }

    return downloadUrls;
  } catch (e) {
    debugLog('Multiple upload error: $e');
    rethrow;
  }
}

/// Delete image from Firebase Storage
Future<void> deleteImage(
  String url, {
  Function(String)? onSuccess,
  Function(String error)? onError,
}) async {
  try {
    // Extract storage path from URL
    final Reference ref = storage.refFromURL(url);
    await ref.delete();

    debugLog('File deleted successfully');
    onSuccess?.call(url);
  } catch (e) {
    debugLog('Delete error: $e');

    if (e is FirebaseException && e.code == 'object-not-found') {
      debugLog('File not found, maybe already deleted');

      onSuccess?.call(url);
    } else {
      if (onError != null) {
        onError(e.toString());
      } else {
        rethrow;
      }
    }
  }
}

/// Delete multiple images from Firebase Storage
Future<void> deleteMultipleImages(
  List<String> urls, {
  Function(int completed, int total)? onProgress,
}) async {
  if (urls.isEmpty) return;

  int completed = 0;
  final futures = <Future<void>>[];

  for (final url in urls) {
    if (url.isNotEmpty) {
      final future = deleteImage(url)
          .then((_) {
            completed++;
            if (onProgress != null) {
              onProgress(completed, urls.length);
            }
          })
          .catchError((e) {
            debugLog('Error deleting image $url: $e');
            completed++;
            if (onProgress != null) {
              onProgress(completed, urls.length);
            }
          });
      futures.add(future);
    }
  }

  await Future.wait(futures);
  debugLog('Deleted ${urls.length} images');
}

void uploadImagePicker(
  BuildContext context, {
  Function(String url)? onUpload,
  Function(String error)? onError,
  Function(double progress)? onProgress,
  String? currentImageUrl,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "select_image_source",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: "close",
                    ),
                  ],
                ),
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text("camera"),
                  onTap: () {
                    Navigator.pop(context);
                    pickAndUploadImages(
                      ImageSource.camera,
                      onUpload: onUpload,
                      onError: onError,
                      onProgress: onProgress,
                      currentImageUrl: currentImageUrl,
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImages(
                    ImageSource.gallery,
                    onUpload: onUpload,
                    onError: onError,
                    onProgress: onProgress,
                    currentImageUrl: currentImageUrl,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> pickAndUploadImages(
  ImageSource source, {
  Function(String url)? onUpload,
  Function(String error)? onError,
  Function(double progress)? onProgress,
  String? currentImageUrl,
}) async {
  final ImagePicker imagePicker = ImagePicker();
  try {
    final XFile? image = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (image == null) return;

    onProgress?.call(0); // Reset progress
    // Upload image to storage - use XFile directly for web compatibility
    final imageUrl = await uploadImage(
      image, // XFile is now supported directly
      onProgress: (progress) {
        onProgress?.call(progress);
      },
      deleteUrl: currentImageUrl, // Delete previous image if exists
    );

    onUpload?.call(imageUrl);
  } catch (e) {
    debugLog('Image upload error: $e');
    onError?.call(e.toString());
  }
}
