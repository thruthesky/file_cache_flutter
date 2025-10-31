// ChatService
// This is a singleton service to manage chat functionalities.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();
  ChatService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;
}
