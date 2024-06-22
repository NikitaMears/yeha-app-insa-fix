import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SiginSiginupButton extends StatelessWidget {
  final String buttonLabel;
  final Function()? buttonPressed;
  const SiginSiginupButton({
    required this.buttonLabel,
    required this.buttonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          const Color(0xff626262),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal:30.w,
            vertical:8.h
          ),
        ),
      ),
      onPressed: buttonPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(
          
            horizontal:15.w,
            vertical:5.h
            ),
        child: Text(
          buttonLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
