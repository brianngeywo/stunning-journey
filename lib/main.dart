import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/DataHandler.dart/appData.dart';
import 'package:uber/screens/SearchScreen.dart';
import 'package:uber/screens/loginscreen.dart';
import 'package:uber/screens/mainscreen.dart';
import 'package:uber/screens/profile.dart';
import 'package:uber/screens/registrationscreen.dart';
import 'package:uber/screens/splashscreen.dart';
import 'package:uber/screens/termsAndCondition.dart';
import 'package:uber/screens/trips.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersref =
    FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'GoTaxi',
        theme: ThemeData(
          fontFamily: "Brand Regular",
          primaryColor: Colors.lightGreen[900],
          accentColor: Colors.lightGreen[50],
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? SplashScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
          SplashScreen.idScreen: (context) => SplashScreen(),
          SearchScreen.idScreen: (context) => SearchScreen(),
          Trips.idScreen: (context) => Trips(),
          Profile.idScreen: (context) => Profile(),
          TermsAndConditions.idScreen: (context) => TermsAndConditions(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
