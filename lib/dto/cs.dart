class CustomerService {
  int idCustomerService;
  String nim;
  String titleIssues;
  String descriptionIssues;
  int rating;
  String? imageUrl;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  CustomerService({
    required this.idCustomerService,
    required this.nim,
    required this.titleIssues,
    required this.descriptionIssues,
    required this.rating,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    required this.deletedAt,
  });

  factory CustomerService.fromJson(Map<String, dynamic> json) =>
      CustomerService(
        idCustomerService: json["id_customer_service"],
        nim: json["nim"],
        titleIssues: json["title_issues"],
        descriptionIssues: json["description_issues"],
        rating: json["rating"],
        imageUrl: json["image_url"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );
}
