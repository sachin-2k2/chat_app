import 'package:chat_app/models/user_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  //Firbase instance

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //register

  Future<UserModel?> resgister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      //create user in firebase

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //create user model
      UserModel user = UserModel(
        usid: credential.user!.uid,
        name: name,
        email: email,
        profileImage: '',
      );

      // Save user data to Firestore
      await _firestore
          .collection('user')
          .doc(credential.user!.uid)
          .set(user.toMap());

      return user;
    } catch (e) {
      print('register error:$e');
      return null;
    }
  }

  //Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(credential.user!.uid)
          .get();

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Login Failed:$e');
      return null;
    }
  }

  //user logout
  Future<void> Logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentuser() {
    return _auth.currentUser;
  }

  //set user online
  Future<void> userOnline(String usid) async {
    await _firestore.collection('user').doc(usid).update({
      'isOnline': true,
      'lastSeen': DateTime.now(),
    });
  }

  //set user offline
  Future<void> userOffline(String usid) async {
    await _firestore.collection('user').doc(usid).update({
      'isOnline': false,
      'lastSeen': DateTime.now(),
    });
  }
}
