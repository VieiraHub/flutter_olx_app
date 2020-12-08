import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/main.dart';
import 'package:olx/models/Ad.dart';
import 'package:olx/util/Settings.dart';
import 'package:olx/views/widgets/ItemAd.dart';

class Adverts extends StatefulWidget {
  @override
  _AdvertsState createState() => _AdvertsState();
}

class _AdvertsState extends State<Adverts> {

  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _itensDropCategoryList;
  List<DropdownMenuItem<String>> _itensDropStateList;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _selectedItemState;
  String _selectedItemCategory;


  _menuItemChoose(String choosenItem) {
    switch (choosenItem) {
      case "My ads" :
        Navigator.pushNamed(context, "/my-ads");
        break;
      case "Log in/ Sign up" :
        Navigator.pushNamed(context, "/login");
        break;
      case "Log out" :
        _logoutUser();
        break;
    }
  }

  _logoutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushNamed(context, "/login");
  }

  Future _verifyLoggedUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();

    if(loggedUser == null) {
      itensMenu = ["Log in/ Sign up"];
    } else {
      itensMenu = ["My ads", "Log out"];
    }
  }

  _loadItensDropdown(){
    _itensDropCategoryList = Settings.getCategories();
    _itensDropStateList = Settings.getStates();
  }

  Future <Stream<QuerySnapshot>> _adsFilter() async {
    Firestore db = Firestore.instance;

    Query query = db.collection("ads");
    if (_selectedItemState != null) {
      query = query.where("state", isEqualTo: _selectedItemState);
    }
    if (_selectedItemCategory != null) {
      query = query.where("category", isEqualTo: _selectedItemCategory);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((data) {  _controller.add(data);  });
  }

  Future <Stream<QuerySnapshot>> _addListenerAds() async {
    Firestore db = Firestore.instance;

    Stream<QuerySnapshot> stream = db.collection("ads").snapshots();
    stream.listen((data) {  _controller.add(data);  });
  }

  @override
  void initState() {
    super.initState();
    _loadItensDropdown();
    _verifyLoggedUser();
    _addListenerAds();
  }


  @override
  Widget build(BuildContext context) {

    var loadingData = Center( child: Column(children: [
      Text("Loading ads"),
      CircularProgressIndicator()
    ]));

    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        elevation: 0,
        actions: [
          PopupMenuButton<String> (
              onSelected: _menuItemChoose,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              }
          )
        ],
      ),
      body: Container(
        child: Container(
          child: Column( children: [
            Row( children: [
              Expanded(
                  child: DropdownButtonHideUnderline(
                      child: Center(
                        child: DropdownButton(
                            iconEnabledColor: Color(0xff9c27b0),
                            value: _selectedItemState,
                            items: _itensDropStateList,
                            style: TextStyle( fontSize: 22, color: Colors.black ),
                            onChanged: (state) {
                              _selectedItemState = state;
                              _adsFilter();
                            }
                        )
                      )
                  )
              ),

              Container(
                color: Colors.grey[200],
                width: 2,
                height: 60
              ),

              Expanded(
                  child: DropdownButtonHideUnderline(
                      child: Center(
                        child: DropdownButton(
                            iconEnabledColor: standardTheme.primaryColor,
                            value: _selectedItemCategory,
                            items: _itensDropCategoryList,
                            style: TextStyle( fontSize: 22, color: Colors.black ),
                            onChanged: (state) {
                              _selectedItemCategory = state;
                              _adsFilter();
                            }
                        )
                      )
                  )
              )
            ]),
            StreamBuilder(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  switch( snapshot.connectionState ) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return loadingData;
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      QuerySnapshot querySnapshot = snapshot.data;

                      if(querySnapshot.documents.length == 0) {
                        return Container(
                          padding: EdgeInsets.all(25),
                          child: Text("No ads",style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          )),
                        );
                      }

                      return Expanded(
                          child: ListView.builder(
                              itemBuilder: (_, index) {
                                List<DocumentSnapshot> ads = querySnapshot.documents.toList();
                                DocumentSnapshot documentSnapshot = ads[index];
                                Ad ad = Ad.fromDocumentSnapshot(documentSnapshot);

                                return ItemAd(
                                  ad: ad,
                                  onTapItem: (){
                                    Navigator.pushNamed(context, "/details-ad", arguments: ad);
                                  }
                                );
                              }
                          )
                      );
                  }
                  return Container();
                }
            )
          ])
        )
      )
    );
  }
}
