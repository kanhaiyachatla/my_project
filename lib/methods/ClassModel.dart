class ClassModel {
  final String name;
  final String description;
  final String photourl;
  final List subjects;
  final String id;

  ClassModel(
      {required this.name,
      required this.description,
      required this.photourl,
        required this.subjects,
      required this.id});

  Map<String, dynamic> toJson() => {
        'name': name,
        'subjects' : subjects,
        'description': description,
        'photourl': photourl,
        'id': id,
      };

  static ClassModel fromJson(Map<String, dynamic> json) => ClassModel(
        name: json['name'],
        description: json['description'],
        photourl: json['photourl'],
        id: json['id'],
        subjects: json['subjects'],
      );
}
