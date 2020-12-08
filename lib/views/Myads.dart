import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Ad.dart';
import 'package:olx/views/widgets/ItemAd.dart';

class Myads extends StatefulWidget {
  @override
  _MyadsState createState() => _MyadsState();
}

class _MyadsState extends State<Myads> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idLoggedUser;


  _recoverLoggedUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;
  }

  Future<Stream<QuerySnapshot>> _addListenerAds() async {
    await _recoverLoggedUserData();

    Firestore db = Firestore.instance;

    Stream<QuerySnapshot> stream = db.collection("my_ads")
        .document(_idLoggedUser).collection("ads").snapshots();
    stream.listen((data) {  _controller.add(data);  });
  }

  _deleteAd(String idAd) {
    Firestore db = Firestore.instance;
    db.collection("my_ads").document(_idLoggedUser)
        .collection("ads").document(idAd).delete().then((_) {
          db.collection("ads").document(idAd).delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _addListenerAds();
  }


  @override
  Widget build(BuildContext context) {

    var loadingData = Center( child: Column( children: [
      Text("Loading ads"), CircularProgressIndicator()
    ]));

    return Scaffold(
      appBar: AppBar( title: Text("My Ads")),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          foregroundColor: Colors.white,
          icon: Icon(Icons.add),
          label: Text("Add"),
          onPressed: () {  Navigator.pushNamed(context, "/new-ad");  }
      ),

      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {

          switch( snapshot.connectionState ) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return loadingData;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError)  return Text("Error loading data!");

              QuerySnapshot querySnapshot = snapshot.data;
              return  ListView.builder(
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (_, index) {
                    List<DocumentSnapshot> ads = querySnapshot.documents.toList();
                    DocumentSnapshot documentSnapshot = ads[index];
                    Ad ad = Ad.fromDocumentSnapshot(documentSnapshot);

                    return ItemAd(
                      ad: ad,
                      onPressedDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Confirm"),
                              content: Text("Really want to delete the Ad"),
                              actions: [
                                FlatButton(
                                  child: Text("Cancel",
                                    style: TextStyle( color:  Colors.grey)
                                  ),
                                  onPressed: () {  Navigator.of(context).pop();  },
                                ),

                                FlatButton(
                                  color: Colors.red,
                                  child: Text("Delete",
                                      style: TextStyle( color:  Colors.white)
                                  ),
                                  onPressed: () {
                                    _deleteAd(ad.id);
                                    Navigator.of(context).pop();
                                  }
                                )
                              ],
                            );
                          }
                        );
                      },
                    );
                  }
              );
          }
          return Container();
        }
      ),
    );
  }
}
