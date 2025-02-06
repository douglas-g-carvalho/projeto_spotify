import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Classe para facilitar o uso da Database do Firebase.
class Database {

  // Referência para facilitar o uso da Database.
  final dbRef = FirebaseDatabase.instance.ref().child('Informações');

  // Função para facilitar o ato de adicionar ou atualizar o conteúdo no Firebase.
  DatabaseReference updateDataBase() {
    return dbRef.child(FirebaseAuth.instance.currentUser!.uid);
  }
}
