import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/widget/widget_support.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
                elevation: 2.0,
                child: Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Center(
                        child: Text(
                      "Ví",
                      style: AppWidget.HeadlineTextFeildStyle(),
                    )))),
            SizedBox(
              height: 30.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                children: [
                  Image.asset(
                    "images/wallet.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: 40.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ví của bạn",
                        style: AppWidget.LightTextFeildStyle(),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "500000" + " VNĐ",
                        style: AppWidget.boldTextFeildStyle(),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Nạp tiền",
                style: AppWidget.semiBooldTextFeildStyle(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "100000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "200000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "300000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "500000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "700000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE9E2E2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "1000000" + " VNĐ",
                    style: AppWidget.semiBooldTextFeildStyle(),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 12),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Color(0xFF008080), borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  "Nạp tiền",
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
