import 'package:firebase_auth/firebase_auth.dart';

Future<void> testFirebase() async {
  try {
    final credential =
    await FirebaseAuth.instance.signInAnonymously();

    print("Firebase OK: ${credential.user?.uid}");
  } catch (e) {
    print(e);
  }
}