import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Ad.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class DetailsAd extends StatefulWidget {

  Ad ad;
  DetailsAd(this.ad);


  @override
  _DetailsAdState createState() => _DetailsAdState();
}

class _DetailsAdState extends State<DetailsAd> {

  Ad _ad;

  List<Widget> _getImagesList() {
    List<String> urlImagesList = _ad.photos;
    return urlImagesList.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth
          )
        )
      );
    }).toList();

  }

  _callTelephone(String telephone) async {
    if( await canLaunch("tel:$telephone") ) {
      await launch("tel:$telephone");
    } else {
      print("Can't do the call");
    }
}

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("Ad")),
      body: Stack(children: [
        ListView(children: [
          SizedBox(
            height: 250,
            child: Carousel(
              images: _getImagesList(),
              dotSize: 8,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              autoplay: false,
              dotIncreasedColor: standardTheme.primaryColor,
            )
          ),

          Container(
            padding: EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("R\$ ${_ad.price}", style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: standardTheme.primaryColor
                  )),

                  Text("${_ad.title}", style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400
                  )),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider()
                  ),

                  Text("Description", style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )),

                  Text("${_ad.description}", style: TextStyle(
                    fontSize: 18
                  )),

                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider()
                  ),

                  Text("Contact", style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )),

                  Padding(
                    padding: EdgeInsets.only(bottom: 66),
                    child: Text("${_ad.telephone}", style: TextStyle(
                        fontSize: 18
                    ))
                  )

                ])
          )
        ]),

        Positioned(
            left: 16, right: 16, bottom: 16,
            child: GestureDetector(
              child: Container(
                child: Text("Call", style: TextStyle(
                  color: Colors.white, fontSize: 20
                )),
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: standardTheme.primaryColor,
                  borderRadius: BorderRadius.circular(30)
                )
              ),
              onTap: () {
                _callTelephone(_ad.telephone);
              },
            )
        )

      ]),
    );
  }
}
