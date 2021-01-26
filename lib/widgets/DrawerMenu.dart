import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/screens/mainscreen.dart';
import 'package:uber/screens/profile.dart';
import 'package:uber/screens/splashscreen.dart';
import 'package:uber/screens/termsAndCondition.dart';
import 'package:uber/screens/trips.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 70,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/user_icon.png",
                    height: 35,
                    width: 35,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Profile Name",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Text("Visit profile"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.idScreen, (route) => false);
          },
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text(
              "Home",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, Trips.idScreen, (route) => false);
          },
          child: ListTile(
            leading: Icon(Icons.turned_in),
            title: Text(
              "Trips",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, Profile.idScreen, (route) => false);
          },
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              "Profile",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, TermsAndConditions.idScreen, (route) => false);
          },
          child: ListTile(
            leading: Icon(Icons.info),
            title: Text(
              "Terms and Conditions",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, SplashScreen.idScreen, (route) => false);
          },
          child: Container(
            color: Colors.grey[200],
            child: ListTile(
              leading: Icon(
                Icons.remove_circle,
                color: Colors.red,
              ),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
