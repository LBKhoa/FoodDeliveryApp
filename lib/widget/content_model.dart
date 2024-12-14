class UnboardingContent {
  String image;
  String title;
  String description;
  UnboardingContent(
      {required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents = [
  UnboardingContent(
      description: 'Chọn món ăn từ thực đơn của chúng tôi\n                    Hơn 35 món ngon',
      image: "images/screen1.png",
      title: '      Chọn từ Thực đơn\n   Tốt nhất của chúng tôi'),
  UnboardingContent(
      description:
      'Bạn có thể trả tiền mặt khi nhận hàng\n          Hoặc thanh toán bằng thẻ',
      image: "images/screen2.png",
      title: 'Dễ dàng Thanh toán\n         Trực tuyến'),
  UnboardingContent(
      description: 'Giao món ăn của bạn đến\n            Tận cửa nhà',
      image: "images/screen3.png",
      title: 'Giao hàng Nhanh đến\n      Cửa nhà bạn')
];
