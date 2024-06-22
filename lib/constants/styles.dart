import 'package:flutter/material.dart';

class Styles {
  static const kInputDecoration = InputDecoration(
    suffixIconColor: Colors.black,
    filled: true,
    fillColor: Color(0xffFFFFFF),
    isCollapsed: true,
    icon: null,
    hintText: 'Search',
    hintStyle: TextStyle(
      fontSize: 18,
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff9A9A9A), width: 1.5),
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9), width: 1.5),
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
    ),
  );
}
