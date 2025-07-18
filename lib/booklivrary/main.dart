
import 'package:booklivraray/booklivrary/detail.dart';
import 'package:booklivraray/booklivrary/home.dart';
import 'package:booklivraray/booklivrary/update.dart';
import 'package:booklivraray/booklivrary/write.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/" : (context) => Home(),
        "/write" : (context) => Write(),
        "/update" : (context) => Update(),
        "/detail" : (context) => Detail(),
      },
    );
  }
}

