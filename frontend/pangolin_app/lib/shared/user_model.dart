class UserModel {
  // final String id;
  // final String name;
  // final int age;
  // final String hobby;
  // final double passionLevel; // 0.0 to 1.0
  // final List<String> subInterests;
  // final List<String> otherInterests;
  // final String? description;

  const UserModel(
    // {
    // required this.id,
    // required this.name,
    // required this.age,
    // required this.hobby,
    // required this.passionLevel,
    // required this.subInterests,
    // required this.otherInterests,
    // this.description,
    // }
  );

  // factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  //   id:             json['id'] as String,
  //   name:           json['name'] as String,
  //   age:            json['age'] as int,
  //   hobby:          json['hobby'] as String,
  //   passionLevel:   (json['passion_level'] as num).toDouble(),
  //   subInterests:   List<String>.from(json['sub_interests'] ?? []),
  //   otherInterests: List<String>.from(json['other_interests'] ?? []),
  //   description:    json['description'] as String?,
  // );

  // Map<String, dynamic> toJson() => {
  //   'id':              id,
  //   'name':            name,
  //   'age':             age,
  //   'hobby':           hobby,
  //   'passion_level':   passionLevel,
  //   'sub_interests':   subInterests,
  //   'other_interests': otherInterests,
  //   'description':     description,
  // };

  // UserModel copyWith({
  //   String? id,
  //   String? name,
  //   int? age,
  //   String? hobby,
  //   double? passionLevel,
  //   List<String>? subInterests,
  //   List<String>? otherInterests,
  //   String? description,
  // }) => UserModel(
  //   id:             id             ?? this.id,
  //   name:           name           ?? this.name,
  //   age:            age            ?? this.age,
  //   hobby:          hobby          ?? this.hobby,
  //   passionLevel:   passionLevel   ?? this.passionLevel,
  //   subInterests:   subInterests   ?? this.subInterests,
  //   otherInterests: otherInterests ?? this.otherInterests,
  //   description:    description    ?? this.description,
  // );
}
