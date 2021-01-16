import 'package:firebase_database/firebase_database.dart';
class Users {
  String id;
  String email;
  String name;
  String phone;

  Users({this.id, this.name, this.phone, this.email});
  Users.fromSnapShot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = dataSnapshot.value["email"];
    phone = dataSnapshot.value["phone"];
    name = dataSnapshot.value["name"];
  }
}