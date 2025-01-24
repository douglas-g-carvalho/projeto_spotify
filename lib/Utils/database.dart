import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Database {
  final dbRef = FirebaseDatabase.instance.ref().child('Informações');

  DatabaseReference updateDataBase() {
    return dbRef.child(FirebaseAuth.instance.currentUser!.uid);
  }
}
