
/// Classe utilitaire représentant un niveau d'enveloppe sur une liste de document lors de la réponse de l'API REST de Firestore.
class FirestoreWrapper {
  final List<dynamic> documents;
  final String nextPageToken;

  FirestoreWrapper({this.documents, this.nextPageToken});

  factory FirestoreWrapper.fromJson(Map<String, dynamic> json) {
    return new FirestoreWrapper(
        documents: json['documents'], nextPageToken: json['nextPageToken']);
  }
}


/// Classe utilitaire représentant un niveau d'enveloppe sur le document.
class FirestoreDocumentWrapper {
  final String name;
  final dynamic fields;
  final dynamic createTime;
  final dynamic updateTime;

  FirestoreDocumentWrapper(
      {this.name, this.fields, this.createTime, this.updateTime});

  factory FirestoreDocumentWrapper.fromJson(Map<String, dynamic> json) {
    return new FirestoreDocumentWrapper(
      name: json['name'],
      fields: json['fields'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }
}
