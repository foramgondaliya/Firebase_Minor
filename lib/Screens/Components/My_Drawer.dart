import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_chat_app/helper/Auth_Helper.dart';

class My_Drawer extends StatefulWidget {
  final User user;
  My_Drawer({required this.user});

  @override
  State<My_Drawer> createState() => _My_DrawerState();
}

class _My_DrawerState extends State<My_Drawer> {
  final GlobalKey<FormState> usernameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userName;
  String? password;

  bool isGoogle() {
    for (var data in widget.user.providerData) {
      if (data.providerId == "google.com") {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (widget.user.isAnonymous)
                      ? null
                      : (widget.user.photoURL == null)
                          ? AssetImage('assets/default_avatar.png')
                          : NetworkImage(widget.user.photoURL!)
                              as ImageProvider,
                ),
                SizedBox(height: 10),
                if (!widget.user.isAnonymous)
                  Text(
                    widget.user.email ?? 'Unknown Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              (widget.user.isAnonymous)
                  ? "Guest Login"
                  : "Username: ${userName ?? 'Unknown'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                AlertBox();
              },
            ),
          ),
          (widget.user.isAnonymous || isGoogle())
              ? Container()
              : ListTile(
                  leading: Icon(
                    Icons.lock,
                  ),
                  title: Text(
                    "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    AlertPassword();
                  },
                ),
        ],
      ),
    );
  }

  void AlertBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Username"),
          content: Form(
            key: usernameKey,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              controller: usernameController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Please enter username first...";
                }
                return null;
              },
              onSaved: (val) {
                userName = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Username",
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                usernameController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (usernameKey.currentState!.validate()) {
                  usernameKey.currentState!.save();

                  User? updatedUser =
                      await Auth_Helper.auth_helper.updateUsername(userName!);
                  if (updatedUser != null) {
                    setState(() {
                      userName = updatedUser.displayName;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Username updated successfully!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update username."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                  usernameController.clear();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void AlertPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reset Password"),
          content: Form(
            key: passwordKey,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              controller: passwordController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Please enter password first...";
                }
                return null;
              },
              onSaved: (val) {
                password = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Password",
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (passwordKey.currentState!.validate()) {
                  passwordKey.currentState!.save();

                  bool isUpdated =
                      await Auth_Helper.auth_helper.updatePassword(password!);

                  if (isUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password updated successfully!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update password."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  passwordController.clear();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
