import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/Model/firebase_model.dart';
import 'package:firebase_chat_app/helper/Auth_Helper.dart';
import 'package:firebase_chat_app/helper/fcm_notification_helper.dart';
import 'package:firebase_chat_app/helper/firebase_helper.dart';
import 'package:firebase_chat_app/helper/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> with WidgetsBindingObserver {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> PhoneNumberKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  String? email;
  String? name;
  int? id;
  int? age;
  String? token;
  String? password;
  String? number;
  Future<void> getFCMToken() async {
    await FcmNotificationHelper.fcmNotificationHelper.fetchFCMToken();
  }

  @override
  void initState() {
    super.initState();
    getFCMToken();
    WidgetsBinding.instance.addObserver(this);
    requestPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    log("==========================");
    log("${state}");
    log("============================");

    switch (state) {
      case AppLifecycleState.paused:
        log("paused");
        break;
      case AppLifecycleState.resumed:
        log("resumed");
        break;
      case AppLifecycleState.detached:
        log("detached");
        break;
      default:
    }
  }

  Future<void> requestPermission() async {
    PermissionStatus notificationPermissionStatus =
        await Permission.notification.request();
    log("=================");
    log("${notificationPermissionStatus}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.3, // 30% of screen height
                    width: MediaQuery.of(context).size.width *
                        0.9, // 90% of screen width
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          "https://img.freepik.com/premium-vector/group-people-phone-chatting-discusses-project-group-conversation-online-chat_530733-2303.jpg",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70),
              Column(
                children: [
                  Container(
                    height: 65,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Map<String, dynamic> res =
                            await Auth_Helper.auth_helper.signInAsGuestUser();

                        if (res['user'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in Successfully..."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.of(context).pushReplacementNamed('/',
                              arguments: res['user']);
                        } else if (res['error'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${res['error']}"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in Failed..."),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Text("Guest Login"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 65,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        validateAndSignInUser();
                      },
                      child: Text("Sign In"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 65,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Map<String, dynamic> res =
                            await Auth_Helper.auth_helper.signInWithGoogle();

                        if (res['user'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in Successfully..."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          User user = res['user'];
                          await FireStoreHelper.fireStoreHelper
                              .addAuthenticatedUser(email: user.email!);

                          Navigator.of(context).pushReplacementNamed('/',
                              arguments: res['user']);
                        } else if (res['error'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${res['error']}"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in Failed..."),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Text("Sign In With Google"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      validateAndSignUpUser();
                    },
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validateAndSignUpUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Sign Up",
          ),
          content: Form(
            key: signUpFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Email First...";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    email = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Email Here",
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: PasswordController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Password First...";
                    } else if (val.length <= 6) {
                      return "Password must Contain 6 Letters";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    password = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Password Here",
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.security,
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                emailController.clear();
                PasswordController.clear();
                email = null;
                password = null;
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () async {
                if (signUpFormKey.currentState!.validate()) {
                  signUpFormKey.currentState!.save();

                  Map<String, dynamic> res = await Auth_Helper.auth_helper
                      .signUpWithEmailAndPassword(
                          email: email!, password: password!);

                  if (res['user'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign up Successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    User user = res['user'];

                    // FirebaseModel firebaseModel = FirebaseModel(email: email!);

                    await FireStoreHelper.fireStoreHelper
                        .addAuthenticatedUser(email: user.email!);

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                      arguments: res['user'],
                    );
                  } else if (res['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${res['error']}"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign in Failed..."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  emailController.clear();
                  PasswordController.clear();
                  email = null;
                  password = null;
                }
              },
              child: Text(
                "Sign Up",
              ),
            ),
          ],
        );
      },
    );
  }

  void validateAndSignInUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Sign In",
          ),
          content: Form(
            key: signInFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Email First...";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    email = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Email Here",
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: PasswordController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Password First...";
                    } else if (val.length <= 6) {
                      return "Password must Contain 6 Letters";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    password = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Password Here",
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.security,
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                emailController.clear();
                PasswordController.clear();
                email = null;
                password = null;
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () async {
                if (signInFormKey.currentState!.validate()) {
                  signInFormKey.currentState!.save();

                  Map<String, dynamic> res = await Auth_Helper.auth_helper
                      .signInWithEmailAndPassword(
                          email: email!, password: password!);

                  if (res['user'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign up Successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (route) => false,
                        arguments: res['user']);
                  } else if (res['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${res['error']}"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign up Failed..."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  }

                  emailController.clear();
                  PasswordController.clear();
                  email = null;
                  password = null;
                }
              },
              child: Text(
                "Sign Up",
              ),
            ),
          ],
        );
      },
    );
  }

  void validateWithPhoneNumber() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Sign Up",
          ),
          content: Form(
            key: PhoneNumberKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: phoneController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter PhoneNumber First...";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    number = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Phone Number Here",
                    labelText: "Number",
                    prefixIcon: Icon(
                      Icons.phone,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                phoneController.clear();
                number = null;
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () async {
                if (PhoneNumberKey.currentState!.validate()) {
                  PhoneNumberKey.currentState!.save();

                  User? user = await Auth_Helper.auth_helper
                      .signInWithMobile(phoneNumber: number!);

                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign up Successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    ;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Sign up Failed..."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  }

                  phoneController.clear();
                  number = null;
                }
              },
              child: Text(
                "Sign Up With Number",
              ),
            ),
          ],
        );
      },
    );
  }
}
