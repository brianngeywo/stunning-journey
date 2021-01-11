import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber/main.dart';
import 'package:uber/screens/loginscreen.dart';
import 'package:uber/screens/mainscreen.dart';
import 'package:uber/widgets/progressDialog.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
                "Sign up as rider",
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "Enter your full name",
                        labelStyle: TextStyle(
                          fontSize: 18,
                        ),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
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
                    SizedBox(height: 5),
                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter your Phone Number",
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
                            "Sign up",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      onPressed: () {
                        if (nameTextEditingController.text.length < 3) {
                          displayToastMsg(
                              "name must be atleast 3 character", context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          displayToastMsg("invalid email address", context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          displayToastMsg(
                              "please input your phone number", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMsg(
                              "password must be atleast 6 characters", context);
                        } else {
                          registerNewUser(context);
                        }
                        CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: Text(
                  "already registered? Login",
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
  registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "processing registration... ",
          );
        });
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
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
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      UsersRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMsg("you can now login to safiri app", context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMsg("user has not been created", context);
    }
  }
}

displayToastMsg(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
