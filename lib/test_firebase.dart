import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebase() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in snapshot.docs) {
      print("USER DOC ID: ${doc.id} -> ${doc.data()}");
    }
  } catch (e) {
    print("ERROR FETCHING USERS: $e");
  }
}