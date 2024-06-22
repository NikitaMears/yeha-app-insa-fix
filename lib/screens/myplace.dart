// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:leaflet_map_app1/Controller/userController.dart';

import 'package:leaflet_map_app1/widgets/leading_icon.dart';

// ignore: must_be_immutable
class MyPlace extends StatefulWidget {
  List<dynamic>? placelist;
  MyPlace({
    Key? key,
    required this.placelist,
  }) : super(key: key);

  @override
  State<MyPlace> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<MyPlace> {
  MapController mapController = MapController();
  TextEditingController labelController = TextEditingController();

  void _showBottomSheet(
    BuildContext context,
    String label,
    double lat,
    double long,
    int placeId,
  ) {
    Marker marker = Marker(
      point: LatLng(lat, long),
      child: Icon(
        Icons.pin_drop,
        color: Colors.red,
      ),
    );
    labelController = TextEditingController(text: label);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.40,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              onTap: (tapPosition, point) {
                             
                                setState(() {
                                  lat = point.latitude;
                                  long = point.longitude;
                                  marker = Marker(
                                    point: LatLng(lat, long),
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: Colors.red,
                                    ),
                                  );
                                });
                                // mapController.move(center, zoom)
                                mapController.move(
                                  LatLng(point.latitude, point.longitude),
                                  10,
                                );
                              },
                              center: LatLng(lat, long),
                              onPositionChanged: (position, hasGesture) {
                              },
                              zoom: 10,
                            ),
                            nonRotatedChildren: [
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                    onTap: () {
                                    },
                                  ),
                                ],
                              ),
                            ],
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  // Marker(
                                  //   // point: LatLng(initialLat!, initialLong!),
                                  //   point: LatLng(lat, long),
                                  //   child: const Icon(
                                  //     Icons.pin_drop,
                                  //     color: Colors.red,
                                  //   ),
                                  // ),
                                  marker
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: labelController,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                 

                                  final response = await API().editPlace(
                                      labelController.text,
                                      lat,
                                      long,
                                      placeId,
                                      context);

                                  if (response == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "you have editted your place successfully,"),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "you have not editted your place successfully,"),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Save",
                                ),
                              ),
                            ],
                          ),
                          // child: Text(
                          //   label,
                          //   textAlign: TextAlign.start,
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.w600,
                          //     fontSize: 24,
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBack(),
        backgroundColor: Colors.blue,
        title: const Text(
          "My Place",
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: widget.placelist!.length,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    _showBottomSheet(
                      context,
                      widget.placelist![index]['properties']?['name'] ?? "",
                      widget.placelist![index]['coordinates'][0],
                      widget.placelist![index]['coordinates'][1],
                      widget.placelist![index]["id"],
                    );
                  },
                  leading: Icon(
                    Icons.place,
                    color: Colors.blue,
                  ),
                  trailing: Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  title: Text(
                    widget.placelist![index]['properties']?['name'] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    widget.placelist![index]['properties']!['label'] ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
