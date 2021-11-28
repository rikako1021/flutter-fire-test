import 'package:flutter/material.dart';

class WidgetUtils {
  static AppBar createAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 2,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
      centerTitle: true,
    );
  }
}