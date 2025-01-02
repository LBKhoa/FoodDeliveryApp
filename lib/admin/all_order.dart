import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Định dạng ngày giờ

class AllUserOrdersPage extends StatelessWidget {
  const AllUserOrdersPage({Key? key}) : super(key: key);

  Stream<QuerySnapshot> getAllOrders() {
    return FirebaseFirestore.instance.collection('orders').snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});
  }

  Future<void> refundWallet(String userId, int amount) async {
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (userSnapshot.exists) {
        int currentWallet = int.parse(userSnapshot['Wallet']);
        int updatedWallet = currentWallet + amount;
        transaction.update(userRef, {'Wallet': updatedWallet.toString()});
      }
    });
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('HH:mm, dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn Hàng Khách Hàng"),
      ),
      body: StreamBuilder(
        stream: getAllOrders(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Hiện chưa có đơn hàng nào.",
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
                String userId = order['userId'];
                Timestamp orderDate = order['orderDate'];
                String status = order['status'];
                int total = order['total'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }

                    if (userSnapshot.hasData) {
                      var user = userSnapshot.data!;
                      String userName = user['Name'] ?? "Không rõ";
                      String address = user['Address'] ?? "Không rõ";

                      return Card(
                        margin: const EdgeInsets.all(10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mã đơn: ${order.id}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text("Tên khách hàng: $userName"),
                              Text("Địa chỉ: $address"),
                              const SizedBox(height: 10),
                              ...items.map((item) {
                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['Name']),
                                    Text(
                                        "${item['Quantity']} x ${item['Total']} VNĐ"),
                                  ],
                                );
                              }).toList(),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tổng tiền:"),
                                  Text(
                                    "$total VNĐ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Trạng thái: $status",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: status == "Hoàn tất"
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Ngày đặt: ${formatDate(orderDate)}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateOrderStatus(order.id, "Xác nhận");
                                    },
                                    child: const Text("Xác nhận"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await updateOrderStatus(order.id, "Hủy đơn");
                                      await refundWallet(userId, total);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Hủy đơn"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                );
              },
            );
          }

          return const Center(child: Text("Đã xảy ra lỗi khi tải dữ liệu."));
        },
      ),
    );
  }
}
