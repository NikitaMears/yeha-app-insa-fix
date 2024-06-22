import 'package:flutter/material.dart';

class LeadingBack extends StatelessWidget {
  const LeadingBack({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          radius: 16,
          child: Icon(
            Icons.arrow_back,
            size: 23,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
