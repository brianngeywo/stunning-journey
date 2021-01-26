import 'package:flutter/material.dart';
import 'package:uber/widgets/DrawerMenu.dart';

class Trips extends StatelessWidget {
  static const String idScreen = "tripsscreen";
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Theme.of(context).accentColor,
        width: 230,
        child: Drawer(
          child: DrawerMenu(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: Center(
              child: Text("trips screen in development"),
            ),
          ),
          //menu icon
          Positioned(
            top: 40,
            left: 15,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Icon(Icons.menu, size: 38),
            ),
          ),
        ],
      ),
    );
  }
}
