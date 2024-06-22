import 'package:flutter/material.dart';

class BottomMeauItem extends StatelessWidget {
  final String lebel;
  final IconData iconData;
  final Color backgoundColor;
  final Color textColor;
  final Function()? buttonCallBack;
  const BottomMeauItem({
    required this.iconData,
    required this.lebel,
    required this.buttonCallBack,
    required this.backgoundColor,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextButton.icon(
          icon: Icon(
            iconData,
            color: textColor,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              backgoundColor,
            ),
          ),
          onPressed: buttonCallBack,
          label: Text(
            lebel,
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
