import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/screens/splashscreen.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: 165,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  "assets/images/user_icon.png",
                  height: 85,
                  width: 85,
                ),
                SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Profile Name",
                      style: TextStyle(fontFamily: "Brand Bold", fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Visit profile"),
                  ],
                )
              ],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.history),
          title: Text(
            "History",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(
            "About",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, SplashScreen.idScreen, (route) => false);
          },
          child: ListTile(
            leading: Icon(Icons.remove_circle,color: Colors.red,),
            title: Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
