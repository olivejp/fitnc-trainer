class Workout {
  String uid;
  String name;
  dynamic createDate;

  Workout({this.uid, this.name, this.createDate});

  factory Workout.fromJson(String uid, Map<String, dynamic> json) {
    return new Workout(
        uid: uid,
        name: json['name'],
        createDate: json['createDate']);
  }

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'name': name, 'createDate': createDate};
}
