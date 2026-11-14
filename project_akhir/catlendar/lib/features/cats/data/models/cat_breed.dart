/// Model respons TheCatAPI (GET /breeds). Bukan entitas ERD dan tidak
/// disimpan ke Firestore; hanya nama breed yang disimpan di CATS.breed.
class CatBreed {
  const CatBreed({required this.id, required this.name});

  final String id;
  final String name;

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
