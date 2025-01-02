import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/check_order.dart';
import 'package:fooddeliveryapp/service/database.dart';
import 'package:fooddeliveryapp/service/shared_pref.dart';
import 'package:fooddeliveryapp/widget/widget_support.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet;
  int total = 0, amount2 = 0;
  Stream? foodStream;

  void startTimer() {
    Timer(Duration(seconds: 1), () {
      amount2 = total;
      setState(() {});
    });
  }

  // Hàm lấy thông tin người dùng
  Future<void> getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  // Hàm tải dữ liệu giỏ hàng
  Future<void> ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    setState(() {});
  }

  // Hàm tạo đơn hàng
  Future<void> createOrder(List<Map<String, dynamic>> cartItems) async {
    try {
      // Thêm thông tin đơn hàng vào Firestore
      await FirebaseFirestore.instance.collection("orders").add({
        "userId": id,
        "total": total,
        "wallet": wallet,
        "items": cartItems,
        "orderDate": DateTime.now(),
        "status": "Chờ xác nhận", // Trạng thái đơn hàng
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Đơn hàng đã được tạo thành công!"),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Có lỗi xảy ra khi tạo đơn hàng!"),
        duration: Duration(seconds: 2),
      ));
      print("Error creating order: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    List<Map<String, dynamic>> cartItems = [];
    try {
      // Truy vấn đúng document ID và collection `Cart`
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('Cart')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          cartItems.add({
            "id": doc.id,
            "Name": doc["Name"],
            "Quantity": doc["Quantity"],
            "Total": doc["Total"],
            "Image": doc["Image"],
          });
        }
      } else {
        print("Cart is empty for user: $userId");
      }
    } catch (e) {
      print("Error fetching cart items: $e");
    }

    return cartItems;
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    startTimer();
  }

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data.docs.isEmpty) {
          return Center(
            child: Text(
              "Giỏ hàng của bạn đang trống",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }

        if (snapshot.hasData) {
          total = snapshot.data.docs
              .fold(0, (sum, doc) => sum + int.parse(doc["Total"]));
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];

              return Dismissible(
                key: Key(ds.id), // Unique key for each item
                direction: DismissDirection.endToStart, // Allow swipe to the left
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // Xử lý xóa mục
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(id)
                      .collection('Cart')
                      .doc(ds.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Món ăn đã được xóa khỏi giỏ hàng!"),
                  ));

                  setState(() {}); // Cập nhật giao diện
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  int currentQuantity =
                                  int.parse(ds["Quantity"]);
                                  if (currentQuantity > 1) {
                                    int newQuantity = currentQuantity - 1;
                                    int pricePerItem = int.parse(ds["Total"]) ~/
                                        currentQuantity;
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(id)
                                        .collection('Cart')
                                        .doc(ds.id)
                                        .update({
                                      "Quantity": newQuantity.toString(),
                                      "Total": (pricePerItem * newQuantity)
                                          .toString(),
                                    });
                                    setState(() {});
                                  }
                                },
                              ),
                              Text(ds["Quantity"]),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  int currentQuantity =
                                  int.parse(ds["Quantity"]);
                                  int newQuantity = currentQuantity + 1;
                                  int pricePerItem = int.parse(ds["Total"]) ~/
                                      currentQuantity;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(id)
                                      .collection('Cart')
                                      .doc(ds.id)
                                      .update({
                                    "Quantity": newQuantity.toString(),
                                    "Total": (pricePerItem * newQuantity)
                                        .toString(),
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          SizedBox(width: 5.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              ds["Image"],
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ds["Name"],
                                style: AppWidget.LightTextFeildStyle(),
                                maxLines: 2,
                              ),
                              Text(
                                ds["Total"] + " VNĐ",
                                style: AppWidget.semiBooldTextFeildStyle(),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Center(child: Text("Đang tải dữ liệu..."));
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
                elevation: 2.0,
                child: Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Center(
                        child: Text(
                      "Giỏ Hàng",
                      style: AppWidget.HeadlineTextFeildStyle(),
                    )))),
            SizedBox(height: 20.0),
            Container(
                height: MediaQuery.of(context).size.height / 2,
                child: foodCart()),
            Spacer(),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng Tiền",
                    style: AppWidget.boldTextFeildStyle(),
                  ),
                  Text(
                    total.toString() + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  )
                ],
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                List<Map<String, dynamic>> cartItems = await getCartItems(id!);

                if (cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Giỏ hàng của bạn đang trống. Không thể tạo đơn hàng!"),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }

                if (amount2 > int.parse(wallet!)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Số dư ví không đủ để thanh toán!"),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }

                await createOrder(cartItems);

                int amount = int.parse(wallet!) - amount2;
                await DatabaseMethods()
                    .UpdateUserwallet(id!, amount.toString());
                await SharedPreferenceHelper()
                    .saveUserWallet(amount.toString());
                await DatabaseMethods().clearCart(id!);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CheckOrder(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Center(
                  child: Text(
                    "Thanh Toán",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
