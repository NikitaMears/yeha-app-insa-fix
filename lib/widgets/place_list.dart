import 'package:flutter/material.dart';

class PlaceList extends StatelessWidget {
  dynamic placedat;
   PlaceList({
  required this.placedat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.place,
          color: Colors.blue,
        ),
        trailing: Icon(
          Icons.edit,
          color: Colors.blue,
        ),
        title: Text(
          placedat['label'],
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          "Your Place Approvial",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }
}
