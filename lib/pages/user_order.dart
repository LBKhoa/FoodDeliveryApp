import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Thêm import này

class UserOrdersPage extends StatelessWidget {
  final String userId; // ID người dùng

  UserOrdersPage({required this.userId});

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('HH:mm, dd/MM/yyyy').format(date); // Định dạng giờ : phút, ngày / tháng / năm
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đơn Hàng Của Tôi"),
      ),
      body: StreamBuilder(
        stream: getUserOrders(userId),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Bạn chưa có đơn hàng nào.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot order = snapshot.data!.docs[index];
                List<dynamic> items = order['items'];
                Timestamp orderDate = order['orderDate']; // Lấy timestamp từ Firestore

                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mã đơn: ${order.id}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...items.map((item) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['Name']),
                              Text("${item['Quantity']} x ${item['Total']} VNĐ"),
                            ],
                          );
                        }).toList(),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tổng tiền:"),
                            Text(
                              "${order['total']} VNĐ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Trạng thái: ${order['status']}",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: order['status'] == "Hoàn tất"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Ngày đặt: ${formatDate(orderDate)}", // Hiển thị ngày đã định dạng
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Center(child: Text("Đã xảy ra lỗi khi tải dữ liệu."));
        },
      ),
    );
  }
}
