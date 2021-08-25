import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//This class holds the methods for user authentication and user creations
class DatabaseMethods {
  // Sign up method
  Future<dynamic> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        return value;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      }
      print('Error here: $e');
      return Future.error(e);
    }
  }

  // sign in method
  Future<dynamic> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    print('Inside here');
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        return value;
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      print('Error here: $e');
      return Future.error(e);
    }
  }

  // Add user data like their names when signing up
  Future<void> addUser(Map<String, dynamic> data, String userId) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .set(data)
        .then((value) {
      print('User Added SuccessFully!');
    }).catchError((error) {
      print('Error Occured: $error');
    });
  }

  // Add the person details ( relative person details )
  Future<String?> addPersonDetails(Map<String, dynamic> data) async {
    String toReturn = '';
    await FirebaseFirestore.instance
        .collection('my-users')
        .add(data)
        .then((value) {
      print('PErson Added SuccessFully!');
      toReturn = 's';
    }).catchError((error) {
      print('Error Occured: $error');
      toReturn = 'f';
    });
    return toReturn;
  }

  // Gets all the persons from the database for displaying
  Future<QuerySnapshot> getPersons(String userId) async {
    return await FirebaseFirestore.instance
        .collection('my-users')
        .where('uid', isEqualTo: userId)
        .get();
  }

  Future<String> uploadDataToUser(map) async {
    return await FirebaseFirestore.instance
        .collection('photos')
        .doc()
        .set(map)
        .then((value) {
      print('Image Uploaded Successfully');
      return 'Successful';
    }).catchError((error) {
      print('Error Uploading Image: $error');
      return 'error';
    });
  }
}
