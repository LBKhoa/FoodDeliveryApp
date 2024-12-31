import 'package:flutter/material.dart';
import 'package:fooddeliveryapp/pages/bottomnav.dart';
import 'package:fooddeliveryapp/widget/round_button.dart';
import '../../widget/color_extension.dart';

class CheckOrder extends StatefulWidget {
  const CheckOrder({Key? key}) : super(key: key);

  @override
  State<CheckOrder> createState() => _CheckOrderState();
}

class _CheckOrderState extends State<CheckOrder> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      // Material là widget cơ bản cho UI Flutter
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        width: media.width,
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          // Scroll view để tránh lỗi tràn màn hình
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20),
                    // Dịch xuống 15 pixel
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: TColor.primaryText,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30), // Khoảng cách phía trên
              Image.asset(
                "images/thank_you.png",
                width: media.width * 0.55,
              ),
              const SizedBox(height: 25),
              Text(
                "Cảm Ơn!",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "đơn đặt hàng",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Đơn đặt hàng của bạn hiện đang được xử lý. Chúng tôi sẽ cho bạn biết sau khi đơn đặt hàng được chọn từ cửa hàng. Kiểm tra trạng thái Đơn hàng của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.primaryText, fontSize: 14),
              ),
              const SizedBox(height: 35),
              RoundButton(
                title: "Quay về trang chủ",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          BottomNav(), // Thay bằng trang đích của bạn
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
