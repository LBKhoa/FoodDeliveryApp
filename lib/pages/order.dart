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

  void startTimer() {
    Timer(Duration(seconds: 1), () {
      amount2 = total;
      setState(() {});
    });
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    super.initState();
  }

  Stream? foodStream;

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
          total = snapshot.data.docs.fold(0, (sum, doc) => sum + int.parse(doc["Total"]));
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 40,
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(ds["Quantity"])),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              ds["Image"],
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            )),
                        SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          children: [
                            Text(
                              ds["Name"],
                              style: AppWidget.LightTextFeildStyle(),
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
              );
            },
          );
        }

        return Center(child: Text("Đang tải dữ liệu..."));
      },
    );
  }

  Future<void> createOrder(List<DocumentSnapshot> cartItems) async {
    try {
      // Chuẩn bị danh sách sản phẩm từ giỏ hàng
      List<Map<String, dynamic>> items = cartItems.map((doc) {
        return {
          "name": doc["Name"],
          "quantity": doc["Quantity"],
          "price": doc["Total"],
        };
      }).toList();

      // Tạo đơn hàng trong Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        "userId": id,
        "items": items,
        "totalPrice": total,
        "status": "Đang xử lý",
        "createdAt": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đơn hàng đã được tạo thành công!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo đơn hàng: $e")),
      );
    }
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
            SizedBox(
              height: 20.0,
            ),
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
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                if (amount2 > int.parse(wallet!)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Số dư ví không đủ để thanh toán!"),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }

                List<DocumentSnapshot> cartItems =
                await foodStream!.first; // Lấy danh sách giỏ hàng

                await createOrder(cartItems); // Tạo đơn hàng

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
            )
          ],
        ),
      ),
    );
  }
}
