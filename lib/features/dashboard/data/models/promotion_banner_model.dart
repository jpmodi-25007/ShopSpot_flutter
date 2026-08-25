class PromotionBanner {
  final String id;
  final String imageUrl;
  final String? title;
  final String? shopId;
  final String? productId;

  PromotionBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.shopId,
    this.productId,
  });

  factory PromotionBanner.fromJson(Map<String, dynamic> json) {
    return PromotionBanner(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      shopId: json['shopId'],
      productId: json['productId'],
    );
  }
}
