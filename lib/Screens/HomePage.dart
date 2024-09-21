import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/Screens/Components/My_Drawer.dart';
import 'package:firebase_chat_app/helper/Auth_Helper.dart';
import 'package:firebase_chat_app/helper/firebase_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    // User user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "homePage",
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () async {
              await Auth_Helper.auth_helper.SignOutUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('Login_Page', (routs) => false);
            },
            icon: Icon(Icons.power_settings_new),
          ),
        ],
      ),
      drawer: (user == null)
          ? Drawer()
          : My_Drawer(
              user: user,
            ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FireStoreHelper.fireStoreHelper.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR : ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  (data == null) ? [] : data.docs;

              return ListView.separated(
                  separatorBuilder: (context, i) {
                    return Divider();
                  },
                  itemCount: allDocs.length,
                  itemBuilder: (context, i) {
                    return (Auth_Helper.firebaseAuth.currentUser!.email ==
                            allDocs[i].data()['email'])
                        ? Container()
                        : Card(
                            elevation: 4,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                              ),
                              title: Text("${allDocs[i].data()['email']}"),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await FireStoreHelper.fireStoreHelper
                                      .deleteUser(docId: allDocs[i].id);
                                },
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  "ChatApp",
                                  arguments: allDocs[i].data(),
                                );
                              },
                            ),
                          );
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
