import 'package:flutter/material.dart';
import 'package:uber/screens/loginscreen.dart';

class SplashScreen extends StatelessWidget {
  static const String idScreen = "splash";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 35),
              Image(
                image: AssetImage("assets/images/logo2.png"),
                width: 300,
                height: 300,
                alignment: Alignment.center,
              ),
              SizedBox(height: 30),
              Text(
                "Safiri App",
                style: TextStyle(
                  fontFamily: "Brand Bold",
                  fontSize: 45,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontSize: 20, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginScreen.idScreen, (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
