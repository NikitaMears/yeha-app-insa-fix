import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leaflet_map_app1/constants/styles.dart';

class InputCell extends StatelessWidget {
  final TextInputType? keyboarTypeInput;
  final String inputLabel;
  final Function()? onFocuse;
  final TextEditingController? controllerFunction;
  const InputCell({
    super.key,
    this.keyboarTypeInput,
    this.controllerFunction,
    this.onFocuse,
    required this.inputLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inputLabel,
            style:  TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xff000000),
            ),
          ),
        SizedBox(height: 5.h),
          TextField(
            controller: controllerFunction,
            onTap: onFocuse,
            keyboardType: keyboarTypeInput,
            decoration: Styles.kInputDecoration.copyWith(hintText: ""),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
