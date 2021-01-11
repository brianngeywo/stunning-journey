import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber/main.dart';
import 'package:uber/screens/mainscreen.dart';
import 'package:uber/screens/registrationscreen.dart';
import 'package:uber/widgets/progressDialog.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image(
                image: AssetImage("assets/images/logo2.png"),
                width: 280,
                height: 280,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1),
              Text(
                "Login as rider",
                style: TextStyle(
                  fontFamily: "Brand Bold",
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Enter your email address",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "Enter your Password",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displayToastMsg("invalid email address", context);
                        } else if (passwordTextEditingController.text.isEmpty) {
                          displayToastMsg("enter you password", context);
                        } else {
                          loginAndAuthenticateUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegistrationScreen.idScreen, (route) => false);
                },
                child: Text(
                  "Not registered? Create new account",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "loggin you in... ",
          );
        });
    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
    )
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMsg(
          "dont worry, its not you, try again later" + errMsg.toString(),
          context);
    }))
        .user;
    if (firebaseUser != null) {
      UsersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          displayToastMsg("you are now logged in", context);

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMsg("create new account", context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMsg("user cannot be signed in", context);
    }
  }
}
