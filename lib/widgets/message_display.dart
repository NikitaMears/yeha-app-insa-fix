import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class MessageDisplay {
  static void showMessage(String message, context, Color color, String title) {
    Flushbar(
      maxWidth: MediaQuery.of(context).size.width * 0.95,
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
      title: title,
      message: message,
      flushbarStyle: FlushbarStyle.FLOATING,
      duration: const Duration(seconds: 6),
    ).show(context);
  }
}
