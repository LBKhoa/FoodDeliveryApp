import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  UpdateUserwallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  // Xóa thông tin người dùng khỏi Firestore
  Future deleteUser(String id) async {
    try {
      // Xóa tài liệu người dùng từ collection 'users'
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      print("Error deleting user from Firestore: $e");
    }
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future addFoodtoCart(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).collection("Cart").snapshots();
  }


  Future<void> clearCart(String userId) async {
    try {
      var cartCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('Cart');

      var snapshots = await cartCollection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete(); // Xóa từng mục trong giỏ hàng
      }
    } catch (e) {
      print("Lỗi khi xóa giỏ hàng: $e");
      throw Exception("Không thể xóa giỏ hàng.");
    }
  }

}
