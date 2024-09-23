import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/helper/Auth_Helper.dart';
import 'package:firebase_chat_app/helper/firebase_helper.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  TextEditingController chatController = TextEditingController();
  TextEditingController editController = TextEditingController();
  bool isTap = false;

  @override
  void initState() {
    super.initState();

    chatController.addListener(() {
      setState(() {
        isTap = chatController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    chatController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receiverEmail =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        toolbarHeight: 100,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('assets/image/img.jpg'),
              radius: 25,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverEmail['email'],
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 14,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder(
                future: FireStoreHelper.fireStoreHelper.fetchAllMessages(
                  receiverEmail: receiverEmail['email'],
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR : ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    Stream<QuerySnapshot<Map<String, dynamic>>>? streamData =
                        snapshot.data;

                    return StreamBuilder(
                      stream: streamData,
                      builder: (context, ss) {
                        if (ss.hasError) {
                          return Center(
                            child: Text("ERROR : ${ss.error}"),
                          );
                        } else if (ss.hasData) {
                          QuerySnapshot<Map<String, dynamic>>? data = ss.data;

                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              allMessages = (data == null) ? [] : data.docs;

                          return (allMessages.isEmpty)
                              ? const Center(
                                  child: Text("No messages"),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: allMessages.length,
                                  itemBuilder: (context, i) {
                                    bool isSender = receiverEmail['email'] !=
                                        allMessages[i].data()['receiverEmail'];
                                    return Align(
                                      alignment: isSender
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSender
                                              ? Colors.white
                                              : Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.3), // Soft shadow effect
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isSender
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                          children: [
                                            PopupMenuButton<String>(
                                              onSelected: (val) async {
                                                if (val == 'delete') {
                                                  return showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Detete Message?",
                                                        ),
                                                        content: Text(
                                                            "Are you Sure you want to delete message?"),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              FireStoreHelper
                                                                  .fireStoreHelper
                                                                  .deleteMessage(
                                                                receiverEmail:
                                                                    receiverEmail[
                                                                        'email'],
                                                                mesaageDocId:
                                                                    allMessages[
                                                                            i]
                                                                        .id,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                "Delete"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                                if (val == 'edit') {
                                                  return showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Edit Message"),
                                                        content: TextFormField(
                                                          decoration:
                                                              const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            hintText:
                                                                "Edit message...",
                                                          ),
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          controller:
                                                              editController,
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              editController
                                                                  .clear();
                                                            },
                                                            child: const Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              FireStoreHelper
                                                                  .fireStoreHelper
                                                                  .updateMessage(
                                                                msg:
                                                                    editController
                                                                        .text,
                                                                receiveremail:
                                                                    receiverEmail[
                                                                        'email'],
                                                                messageDocId:
                                                                    allMessages[
                                                                            i]
                                                                        .id,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              editController
                                                                  .clear();
                                                            },
                                                            child: const Text(
                                                              "Edit",
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text('Delete'),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text('Edit'),
                                                ),
                                              ],
                                              position: PopupMenuPosition.under,
                                              child: Text(
                                                "${allMessages[i].data()['msg']}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "08:10",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: chatController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter message here...",
                  suffixIcon: IconButton(
                    onPressed: isTap
                        ? () async {
                            String msg = chatController.text;
                            await FireStoreHelper.fireStoreHelper.sendMessage(
                              msg: msg,
                              receiverEmail: receiverEmail['email'],
                            );
                            chatController.clear();
                          }
                        : null,
                    icon: Icon(
                      Icons.send,
                      color: isTap ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
