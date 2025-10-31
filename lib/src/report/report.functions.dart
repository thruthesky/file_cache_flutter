import 'package:firebase_database/firebase_database.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

String get reportPath {
  return 'reports';
}

DatabaseReference myReportRef() {
  return FirebaseDatabase.instance.ref(reportPath).child(myUid());
}

String get reportListPath {
  return 'reports-list';
}

DatabaseReference reportsListRef() {
  return FirebaseDatabase.instance.ref(reportListPath);
}

/// Helper function to generate the report path for a room
String getReportRoomPath(String roomId) {
  return '$chatRoomsPath$roomId';
}

/// Helper function to generate the report path for a message
String getReportMessagePath(String messageId, String roomId) {
  return '${chatMessagePath(roomId)}/$messageId';
}

Future<void> createReport({
  required String path,
  required String reason,
  String? reportee,
  required Function() success,
  required Function(String error) error,
}) async {
  try {
    DataSnapshot snapshot = await myReportRef()
        .orderByChild('path')
        .equalTo(path)
        .get();

    if (snapshot.exists) {
      throw ('You already have reported this.');
    }

    final data = {
      REPORT_PATH: path,
      REPORT_REPORTER: myUid(),
      REPORT_REPORTEE: reportee,
      REPORT_REASON: reason,
      REPORT_CREATED_AT: ServerValue.timestamp,
    };

    DatabaseReference ref = myReportRef().push();
    await ref.set(data);

    await reportsListRef().child(ref.key!).set(data);

    success();
  } catch (e) {
    error(e.toString());
  }
}
