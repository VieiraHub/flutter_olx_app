import 'package:flutter/material.dart';
import 'package:olx/models/Ad.dart';

class ItemAd extends StatelessWidget {

  Ad ad;
  VoidCallback onTapItem;
  VoidCallback onPressedDelete;


  ItemAd({
    @required this.ad,
    this.onTapItem,
    this.onPressedDelete
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Row( children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  ad.photos[0],
                  fit: BoxFit.cover
                )
              ),

              Expanded(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ad.title,
                              style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold
                              )
                            ),
                            Text("R\$ ${ad.price}")
                      ]),
                  )
              ),

              if( this.onPressedDelete != null ) Expanded(
                  flex: 1,
                  child: FlatButton(
                      color: Colors.red,
                      padding: EdgeInsets.all(10),
                      onPressed: this.onPressedDelete,
                      child: Icon(Icons.delete, color: Colors.white)
                  )
              )
            ])
        )
      )
    );
  }
}
