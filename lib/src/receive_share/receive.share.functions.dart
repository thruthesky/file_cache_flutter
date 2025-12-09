import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo_api/philgo_api.dart';

Future<String?> showReceiveShareDialog(
  BuildContext context,
  List<SharedMediaFile> data,
) async {
  final picked = await showDialog<String?>(
    context: context,
    builder: (context) => ReceiveShareDialog(data: data),
  );
  return picked;
}

Future<void> sendReceiveShareToChat(
  String roomId,
  List<SharedMediaFile> data,
) async {
  // Shared from highlighted text only
  if (data.length == 1 && await isSharedMediaPlainText(data[0])) {
    await sendMessage(roomId: roomId, text: data[0].path);
  } else {
    List<Future> promises = [];
    for (SharedMediaFile file in data) {
      promises.add(uploadReceivedFilesAndSentToChat(roomId, file));
    }
    if (promises.isNotEmpty) {
      await Future.wait(promises);
    }
  }
}

Future<String> uploadReceivedFilesAndSentToChat(
  String roomId,
  SharedMediaFile file,
) async {
  String url = await uploadReceivedFile(file);
  await sendMessage(text: '', urls: [url], roomId: roomId);
  return url;
}

Future<String> uploadReceivedFile(SharedMediaFile file) async {
  XFile xFile = XFile(file.path);

  final url = await uploadImage(
    xFile, // XFile is now supported directly
  );
  return url;
}

Future<bool> canShareToChat(List<SharedMediaFile> files) async {
  if (files.length == 1 && await isSharedMediaPlainText(files[0])) return true;
  bool canShare = true;
  for (SharedMediaFile file in files) {
    if (file.type != SharedMediaType.image) {
      canShare = false;
      break;
    }
  }
  return canShare;
}

Future<bool> isSharedMediaPlainText(SharedMediaFile file) async {
  if (file.type != SharedMediaType.text) return false;
  final fileExist = await File(file.path).exists();
  log(fileExist ? 'true' : 'false', name: "isFileExist::");
  if (fileExist) return false;
  return true;
}
