
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';

class ApplicationName extends StatelessWidget {
  const ApplicationName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "ETHIO",
            textDirection: null,
            style: TextStyle(
              color: Color(0xff626262),
              fontWeight: FontWeight.w400,
              fontSize: 36.sp,
            ),
          ),
          Text(
            'MAPS',
            textDirection: null,
            style: TextStyle(
              color: Color(0xff626262),
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
            ),
          ),
        ],
      ),
    );
  }
}