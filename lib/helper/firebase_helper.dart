import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/Model/firebase_model.dart';
import 'package:firebase_chat_app/helper/Auth_Helper.dart';
import 'package:firebase_chat_app/helper/fcm_notification_helper.dart';

class FireStoreHelper {
  FireStoreHelper._();
  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addAuthenticatedUser({required String email}) async {
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
      Map<String, dynamic> docData = doc.data();

      if (docData['email'] == email) {
        isUserExists = true;
      }
    });
    if (isUserExists == false) {
      DocumentSnapshot<Map<String, dynamic>> qs =
          await db.collection("records").doc("users").get();

      Map<String, dynamic>? data = qs.data();

      int id = data!['id'];
      int counter = data!['counter'];

      id++;
      String? token =
          await FcmNotificationHelper.fcmNotificationHelper.fetchFCMToken();

      await db.collection("users").doc("$id").set({
        "email": email,
        "token": token,
      });
      counter++;

      await db.collection("records").doc("users").update({
        "id": id,
        "counter": counter,
      });
    }
  }

  //fetch all users
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return db.collection("users").snapshots();
  }
//delete user

  Future<void> deleteUser({required String docId}) async {
    await db.collection("users").doc(docId).delete();

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection("records").doc("users").get();

    int counter = userDoc.data()!['counter'];

    counter--;

    await db.collection('records').doc("users").update(
      {
        "counter": counter,
      },
    );
  }
  //create a chatroom and store a message

  Future<void> sendMessage(
      {required String msg, required String receiverEmail}) async {
    String senderEmail = Auth_Helper.firebaseAuth.currentUser!.email!;

    bool isChatroomExists = false;

    //check if a chatroom is already exist or not

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        isChatroomExists = true;
        chatroomId = chatroom.id;
      }
    });
    if (isChatroomExists == false) {
      DocumentReference<Map<String, dynamic>> docRef =
          await db.collection("chatrooms").add({
        "users": [senderEmail, receiverEmail]
      });
      chatroomId = docRef.id;
    }
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .add({
      "msg": msg,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchAllMessages(
      {required String receiverEmail}) async {
    String senderEmail = Auth_Helper.firebaseAuth.currentUser!.email!;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatroons =
        querySnapshot.docs;

    String? chatroomId;

    allChatroons
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];
      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
    });
    return db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
  //delete message

  Future<void> deleteMessage(
      {required String receiverEmail, required String mesaageDocId}) async {
    String? senderEmail = Auth_Helper.firebaseAuth.currentUser!.email;

    //find a chatroom id

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
    });
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(mesaageDocId)
        .delete();
  }
  //update message

  Future<void> updateMessage(
      {required String msg,
      required String receiveremail,
      required String messageDocId}) async {
    String? senderEmail = Auth_Helper.firebaseAuth.currentUser!.email;

    //find a chatroom id

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms.forEach(
      (QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
        List users = chatroom.data()['users'];

        if (users.contains(receiveremail) && users.contains(senderEmail)) {
          chatroomId = chatroom.id;
        }
      },
    );
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .update({
      "msg": msg,
      "updatedTimeStamp": FieldValue.serverTimestamp(),
    });
  }
}
