import 'package:firebase_database/firebase_database.dart';

class ChatService {

  final database = FirebaseDatabase.instance.ref();

  // SEND MESSAGE
  Future<void> sendMessage({
    required String roomId,
    required int senderId,
    required int receiverId,
    required String message,
  }) async {

    await database
        .child('chat_rooms')
        .child(roomId)
        .child('messages')
        .push()
        .set({

      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // GET MESSAGES
  DatabaseReference getMessages(String roomId) {

    return database
        .child('chat_rooms')
        .child(roomId)
        .child('messages');
  }
}