import 'package:firebase_auth/firebase_auth.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getCurrenUser() async {
    return await auth.currentUser;
  }

  Future SignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Xóa trạng thái đăng nhập
    await FirebaseAuth.instance.signOut();
  }

  Future deleteUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      // Xóa dữ liệu người dùng từ SharedPreferences
      await SharedPreferenceHelper().clearUserData();

      // Xóa thông tin người dùng khỏi Firestore
      await DatabaseMethods().deleteUser(uid);

      // Xóa người dùng khỏi Firebase Authentication
      await user.delete();

    }
  }
}
