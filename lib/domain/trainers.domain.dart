class Trainers {
  String uid;
  String email;

  Trainers({this.uid, this.email});

  factory Trainers.fromJson(String uid, Map<String, dynamic> json) {
    return new Trainers(uid: uid, email: json['email']);
  }

  Map<String, dynamic> toJson() => {'uid': uid, 'email': email};
}
