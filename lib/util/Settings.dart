import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';

class Settings {

  static List<DropdownMenuItem<String>> getStates() {
    List<DropdownMenuItem<String>> itensDropStateList = [];

    itensDropStateList.add(
        DropdownMenuItem(child: Text("State",
          style: TextStyle( color: Color(0xff9c27b0)),
        ), value: null)
    );

    for(var state in Estados.listaEstadosAbrv) {
      itensDropStateList.add(
          DropdownMenuItem(child: Text(state), value: state)
      );
    }

    return itensDropStateList;
  }

  static List<DropdownMenuItem<String>> getCategories() {
    List<DropdownMenuItem<String>> itensDropCategories = [];

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Category",
          style: TextStyle( color: Color(0xff9c27b0)),
        ), value: null)
    );

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Automobile"), value: "Auto")
    );

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Houses"), value: "houses")
    );

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Electronics"), value: "electro")
    );

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Fashion"), value: "fashion")
    );

    itensDropCategories.add(
        DropdownMenuItem(child: Text("Sports"), value: "sports")
    );

    return itensDropCategories;
  }

}