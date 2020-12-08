
import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {

  String _id;
  String _state;
  String _category;
  String _title;
  String _price;
  String _telephone;
  String _description;
  List<String> _photos;

  Ad();

  Ad.fromDocumentSnapshot( DocumentSnapshot documentSnapshot ) {
    this.id = documentSnapshot.documentID;
    this.state = documentSnapshot["state"];
    this.category = documentSnapshot["category"];
    this.title = documentSnapshot["title"];
    this.price = documentSnapshot["price"];
    this.telephone = documentSnapshot["telephone"];
    this.description = documentSnapshot["description"];
    this.photos = List<String>.from(documentSnapshot["photos"]);
  }

  Ad.generateId(){
   Firestore db = Firestore.instance;
   CollectionReference ads = db.collection("my_ads");
   this.id = ads.document().documentID;
   this.photos = [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id" : this.id,
      "state" : this.state,
      "category" : this.category,
      "title" : this.title,
      "price" : this.price,
      "telephone" : this.telephone,
      "description" : this.description,
      "photos" : this.photos,
    };
    return map;
  }

  List<String> get photos => _photos;

  set photos(List<String> value) {  _photos = value;  }

  String get description => _description;

  set description(String value) {  _description = value;  }

  String get telephone => _telephone;

  set telephone(String value) {  _telephone = value;  }

  String get price => _price;

  set price(String value) {  _price = value;  }

  String get title => _title;

  set title(String value) {  _title = value;  }

  String get category => _category;

  set category(String value) {  _category = value;  }

  String get state => _state;

  set state(String value) {  _state = value;  }

  String get id => _id;

  set id(String value) {  _id = value;  }
}