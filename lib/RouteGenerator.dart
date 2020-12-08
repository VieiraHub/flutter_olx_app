import 'package:flutter/material.dart';
import 'package:olx/views/Adverts.dart';
import 'package:olx/views/DetailsAd.dart';
import 'package:olx/views/Login.dart';
import 'package:olx/views/Myads.dart';
import 'package:olx/views/NewAd.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch (settings.name) {
      case "/" :
        return MaterialPageRoute(  builder: (_) => Adverts()  );
      case "/login" :
        return MaterialPageRoute(  builder: (_) => Login()  );
      case "/my-ads" :
        return MaterialPageRoute(  builder: (_) => Myads()  );
      case "/new-ad" :
        return MaterialPageRoute(  builder: (_) => NewAd()  );
      case "/details-ad" :
        return MaterialPageRoute(  builder: (_) => DetailsAd(args)  );
      default:
        _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar( title: Text("View not found!")),
          body: Center( child: Text("View not found!")),
        );
      }
    );
  }
}