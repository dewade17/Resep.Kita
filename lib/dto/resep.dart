class Resep {
  final int idResep;
  final int idUser;
  final String imageResep;
  final String namaPublic;
  final String title;
  final String description;
  final String kategori;
  final List<String> ingredients;
  final List<int> stepNumbers;
  final List<String> instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resep({
    required this.idResep,
    required this.idUser,
    required this.imageResep,
    required this.namaPublic,
    required this.title,
    required this.description,
    required this.kategori,
    required this.ingredients,
    required this.stepNumbers,
    required this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Resep.fromJson(Map<String, dynamic> json) {
    return Resep(
      idResep: json["id_resep"],
      idUser: json["id_user"],
      imageResep: json["image_resep"],
      namaPublic: json["nama_public"],
      title: json["title"],
      description: json["description"],
      kategori: json["kategori"],
      ingredients:
          List<String>.generate(10, (i) => json["nama_bahan_${i + 1}"] ?? ''),
      stepNumbers:
          List<int>.generate(10, (i) => json["step_number_${i + 1}"] ?? 0),
      instructions:
          List<String>.generate(10, (i) => json["instruksi_${i + 1}"] ?? ''),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "id_resep": idResep,
      "id_user": idUser,
      "image_resep": imageResep,
      "nama_public": namaPublic,
      "title": title,
      "description": description,
      "kategori": kategori,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };

    for (int i = 0; i < ingredients.length; i++) {
      data["nama_bahan_${i + 1}"] = ingredients[i];
    }

    for (int i = 0; i < stepNumbers.length; i++) {
      data["step_number_${i + 1}"] = stepNumbers[i];
    }

    for (int i = 0; i < instructions.length; i++) {
      data["instruksi_${i + 1}"] = instructions[i];
    }

    return data;
  }
}
