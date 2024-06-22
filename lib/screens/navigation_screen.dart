// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:leaflet_map_app1/constants/styles.dart';
import 'package:leaflet_map_app1/widgets/message_display.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:osrm/osrm.dart';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NavigationScreen extends StatefulWidget {
  final double? fromLat;
  final double? fromLong;
  final double? toLat;
  final double? toLong;
  const NavigationScreen({
    super.key,
    this.fromLat,
    this.fromLong,
    this.toLat,
    this.toLong,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  List<dynamic> _suggestions = [];
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<LatLng> routePoints = [];
  List<dynamic> routes = [];
  List<dynamic> steps = [];
  bool isAppBarExpanded = true;
  double? fromLat;
  double? fromLong;
  double? fromLatSwap;
  double? fromLongSwap;
  double? toLat;
  double? toLong;
  double? initialLat;
  double? initialLong;
  LatLng from = const LatLng(37.473662, 3.825987);
  LatLng fromLatLong = const LatLng(37.473662, 3.825987);

  var to = const LatLng(36.473662, 2.825987);
  var points = <LatLng>[];
  var activeRouteIndex = 0;
  var selectedProfile = 0;
  bool _isLoading = false;

  final String? api_key = dotenv.env["API_KEY"];
  final String? base_url = dotenv.env["BASE_URL"];

  @override
  void initState() {
    super.initState();
    // main();
    // _getCurrentLocation();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          isAppBarExpanded) {
        setState(() {
          isAppBarExpanded = false;
        });
      }
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !isAppBarExpanded) {
        setState(() {
          isAppBarExpanded = true;
        });
      }
    });

    if (widget.fromLat == null ||
        widget.fromLong == null ||
        widget.toLat == null ||
        widget.toLong == null) {
    } else {
      void mehtod() async {
        from = LatLng(widget.fromLat!, widget.fromLong!);
        fromController.text =
            await reverseGeocode(widget.fromLat, widget.fromLong);
        to = LatLng(widget.toLat!, widget.toLong!);
        fromLat = widget.fromLat;
        fromLong = widget.fromLong;
        toLat = widget.toLat;
        toLong = widget.toLong;

        toController.text = await reverseGeocode(widget.toLat, widget.toLong);
      }

      mehtod();

      navigate(widget.fromLat, widget.fromLong, widget.toLat, widget.toLong);
    }
  }

  Future<String> reverseGeocode(double? lat, double? lon) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final address = data['display_name'];
   
    // final city = address['city'];
    // final state = address['state'];
    // final country = address['country'];
    return address;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 220.h,
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Card(
                    color:
                        activeRouteIndex == index ? Colors.grey : Colors.white,
                    elevation: 8,
                    child: ListTile(
                      leading: const Icon(Icons.directions_rounded),
                      title: Text("Route ${index + 1}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            '${(routes[index]["distance"] / 1000).toStringAsFixed(2)} km',
                            style: TextStyle(
                                color: Colors.grey[550], fontSize: 14),
                          ),
                          Text(
                            '${(routes[index]["duration"] / 3600).toStringAsFixed(2)} hr',
                            style: TextStyle(
                              color: Colors.grey[550],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          activeRouteIndex = index;
                          routePoints = [];
                          steps = routes[index]["legs"][0]["steps"];

                          var ruter = routes[index]['geometry']['coordinates'];
                          distance = routes[index]["distance"];
                          duration = routes[index]["duration"];
                          for (int i = 0; i < ruter.length; i++) {
                            var reep = ruter[i].toString();
                            reep = reep.replaceAll("[", "");
                            reep = reep.replaceAll("]", "");
                            var lat1 = reep.split(',');
                            var long1 = reep.split(",");
                            routePoints.add(
                              LatLng(
                                double.parse(lat1[1]),
                                double.parse(long1[0]),
                              ),
                            );
                          }
                        });
                        Navigator.pop(context);
                        _showStepsBottomSheet(context);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  void _showStepsBottomSheet(BuildContext context) {
    // _startModelTimer();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            height: 220.h,
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 8,
                  child: ListTile(
                    // leading: const Icon(Icons.directions_rounded),
                    //                 leading: switch (steps[index]["maneuver"]["modifier"]) {
                    //   case 'left':
                    //     icon = Icons.arrow_left;
                    //     break;
                    //   case 'right':
                    //     icon = Icons.arrow_right;
                    //     break;
                    //   case 'straight':
                    //     icon = Icons.arrow_upward;
                    //     break;
                    //   case 'slight left':
                    //     icon = Icons.subdirectory_arrow_left;
                    //     break;
                    //   case 'slight right':
                    //     icon = Icons.subdirectory_arrow_right;
                    //     break;
                    //   default:
                    //     icon = Icons.error;
                    // },
                    leading: steps[index]["maneuver"]["modifier"] == 'left'
                        ? Icon(Icons.turn_left)
                        : steps[index]["maneuver"]["modifier"] == 'right'
                            ? Icon(Icons.turn_right)
                            : steps[index]["maneuver"]["modifier"] == 'straight'
                                ? Icon(Icons.arrow_upward)
                                : steps[index]["maneuver"]["modifier"] ==
                                        'slight left'
                                    ? Icon(Icons.turn_slight_left)
                                    : Icon(Icons.turn_slight_right),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        steps[index]["maneuver"]["modifier"] == 'straight'
                            ? Text("Go ${steps[index]["maneuver"]["modifier"]}")
                            : Text(
                                "Turn ${steps[index]["maneuver"]["modifier"]}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(steps[index]["distance"].toStringAsFixed(2) +
                                " m"),
                            Text(steps[index]["duration"].toStringAsFixed(2) +
                                " sec"),
                          ],
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ));
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    setState(() {
      initialLat = locationData.latitude!;
      initialLong = locationData.longitude!;
      from = LatLng(initialLat!, initialLong!);
      // markerLat = initialLat;
      // markerLong = initialLong;
      // getLocationName(initialLat!, initialLong!);
      // routpoints.add(LatLng(initialLat!, initialLong!));
    });
  }

  void main() {
    const oneSec = const Duration(seconds: 10);
    Timer.periodic(oneSec, (Timer timer) {
      _getCurrentLocation();
      navigate(initialLat, initialLong, widget.toLat, widget.toLong);
      // Call your function here
    });
  }

  // Future<void> _getSuggestions(String query) async {
  //   try {
  //     // final response = await http
  //     // .get(Uri.parse('http://69.143.1.168:4000/v1/search?text=$query'));
  //     final response = await http.get(Uri.parse(
  //         'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&polygon_svg=1&countrycodes=et'));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);


  //       setState(() {
  //         // _suggestions = data["features"].map((e) => e).toList();
  //         _suggestions = data.map((e) => e).toList();

  //       });
  //     } else {
  //       throw Exception('Failed to load suggestions');
  //     }
  //   } on SocketException {
  //     MessageDisplay.showMessage(
  //         "Network is unreachable! Please check your internet connection.",
  //         context,
  //         Colors.red,
  //         "Error");
  //   } on TimeoutException {
  //     MessageDisplay.showMessage("Network is timedout please try again later",
  //         context, Colors.red, "Error");
  //   }
  // }

  Future<void> _getSuggestions(String query) async {
    try {
      // final response = await http
      //     .get(Uri.parse('http://69.250.70.104:4000/v1/search?text=$query'));
      final response = await http.get(
          Uri.parse('${base_url}API_KEY=$api_key&service=search&text=$query'));

      // final response = await http.get(Uri.parse(
      // 'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&polygon_svg=1&countrycodes=et'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      
        setState(() {
          _suggestions = data["features"].map((e) => e).toList();
          // _suggestions = data.map((e) => e).toList();

        });
      } else {
        throw Exception('Failed to load suggestions');
      }
    } on SocketException {
      // ignore: use_build_context_synchronously
      MessageDisplay.showMessage(
        "Network is unreachable! Please check your internet connection.",
        context,
        Colors.red,
        "Error",
      );
    } on TimeoutException {
      // ignore: use_build_context_synchronously
      MessageDisplay.showMessage(
        "Network is timedout please try again later",
        context,
        Colors.red,
        "Error",
      );
    }
  }

  /// [distance] the distance between two coordinates [from] and [to]
  num distance = 0.0;

  /// [duration] the duration between two coordinates [from] and [to]
  num duration = 0.0;

  /// [getRoute] get the route between two coordinates [from] and [to]
  Future<void> getRoute() async {
    final osrm = Osrm(
      source: OsrmSource(
        serverBuilder: OpenstreetmapServerBuilder().build,
      ),
    );
    if (kDebugMode) {
    }
    setState(() {});
  }

  void navigate(
      double? fromLat, double? fromLong, double? toLat, double? toLong) async {
    _isLoading = true;
    // var url = Uri.parse(
    //     'http://router.project-osrm.org/route/v1/driving/$fromLong,$fromLat;$toLong,$toLat?steps=true&annotations=true&geometries=geojson&overview=full');
    //var url = Uri.parse(
    //"http://69.250.70.104:5000/route/v1/driving-car/$fromLong,$fromLat;$toLong,$toLat?alternatives=2&steps=true&geometries=geojson");
    var url = Uri.parse(
        "${base_url}API_KEY=$api_key&service=routing&text=$fromLong,$fromLat;$toLong,$toLat");
    var response = await http.get(url);

    setState(() {
      routePoints = [];
      var resData = jsonDecode(response.body)["routes"];
          routes = resData;
      steps = routes[activeRouteIndex]["legs"][0]["steps"];
      // _startModelTimer();

      var ruter =
          jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
      // distance = jsonDecode(
      // response.body)['routes'][0]
      // ["distance"];
      // duration = jsonDecode(
      // response.body)['routes'][0]
      // ["duration"];
      // activeRoute = resData[0];
      for (int i = 0; i < ruter.length; i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "");
        reep = reep.replaceAll("]", "");
        var lat1 = reep.split(',');
        var long1 = reep.split(",");
        routePoints.add(
          LatLng(
            double.parse(lat1[1]),
            double.parse(long1[0]),
          ),
        );
      }
      // isVisible = !isVisible;
      _isLoading = false;
    });
  }

  // navigate with out the loader
  void navigateMap(
      double? fromLat, double? fromLong, double? toLat, double? toLong) async {
    // _isLoading = true;
    // var url = Uri.parse(
    //     'http://router.project-osrm.org/route/v1/driving/$fromLong,$fromLat;$toLong,$toLat?steps=true&annotations=true&geometries=geojson&overview=full');
    var url = Uri.parse(
        "http://69.243.101.217:5000/route/v1/driving-car/$fromLong,$fromLat;$toLong,$toLat?alternatives=2&steps=true&geometries=geojson");
    var response = await http.get(url);

    setState(() {
      routePoints = [];
      var resData = jsonDecode(response.body)["routes"];
    
      routes = resData;
      steps = routes[activeRouteIndex]["legs"][0]["steps"];
      // _startModelTimer();

      var ruter =
          jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
      // distance = jsonDecode(
      // response.body)['routes'][0]
      // ["distance"];
      // duration = jsonDecode(
      // response.body)['routes'][0]
      // ["duration"];
      // activeRoute = resData[0];
      for (int i = 0; i < ruter.length; i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "");
        reep = reep.replaceAll("]", "");
        var lat1 = reep.split(',');
        var long1 = reep.split(",");
        routePoints.add(
          LatLng(
            double.parse(lat1[1]),
            double.parse(long1[0]),
          ),
        );
      }
      // isVisible = !isVisible;
      // _isLoading = false;
    });
  }

  // pairly
  bool isPairly = false;

  Timer? _modelTimer;
  Timer? _mapTimer;

  int currentIndex = 0;

  var model;
  double? doubleDuration;
  int? intDuration;
  bool isNavigationStarted = false;

  void _startModelTimer() {
    setState(() {
      model = steps[currentIndex];
      doubleDuration = model["duration"];
      intDuration = doubleDuration!.ceil();
    });
    _modelTimer = Timer(Duration(seconds: intDuration!), _showNextModel);
  }

// start map real time navigation
  void _startMapTimer() {
    _mapTimer = Timer(Duration(seconds: 5), _showNextMap);
  }

  void _showNextModel() {
    _modelTimer?.cancel(); // Cancel the existing timer

    setState(() {
      currentIndex = (currentIndex + 1) % steps.length;
    }); // Trigger a rebuild
    _startModelTimer(); // Start a new timer for the next model
  }

  void _showNextMap() async {
    _mapTimer?.cancel(); // Cancel the existing timer
    await _getCurrentLocation();
    navigateMap(initialLat, initialLong, widget.toLat, widget.toLong);
    setState(() {}); // Trigger a rebuild
    _startMapTimer(); // Start a new timer for the next model
  }

  @override
  void dispose() {
    _modelTimer?.cancel();
    // Clean up the timer
    _mapTimer?.cancel();
    super.dispose();
  }

  // bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   toController.text = widget.nameIntialLocation!;
    //   toController.text = widget.nameFinalLocation!;
    //   fromLat = widget.latiIntial;
    //   fromLong = widget.longIntial;
    //   toLat = widget.latiFinal;
    //   toLong = widget.longFinal;
    // });
    var center = (routePoints.length) / 2.toInt();

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   onPressed: () {
      //     _showBottomSheet(context);
      //   },
      //   child: const Icon(Icons.route),
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          isNavigationStarted
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 150,
                    child: steps.length > 0
                        ? Row(
                            children: [
                              steps[currentIndex]["maneuver"]["modifier"] ==
                                      'left'
                                  ? Icon(Icons.turn_left)
                                  : steps[currentIndex]["maneuver"]
                                              ["modifier"] ==
                                          'right'
                                      ? Icon(Icons.turn_right)
                                      : steps[currentIndex]["maneuver"]
                                                  ["modifier"] ==
                                              'straight'
                                          ? Icon(Icons.arrow_upward)
                                          : steps[currentIndex]["maneuver"]
                                                      ["modifier"] ==
                                                  'slight left'
                                              ? Icon(Icons.turn_slight_left)
                                              : Icon(Icons.turn_slight_right),
                              SizedBox(
                                width: 5,
                              ),
                              steps[currentIndex]["maneuver"]["modifier"] ==
                                      'straight'
                                  ? Expanded(
                                      child: Text(
                                        "Go ${steps[currentIndex]["maneuver"]["modifier"]}",
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : Expanded(
                                      child: Text(
                                        "Turn ${steps[currentIndex]["maneuver"]["modifier"]}",
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                            ],
                          )
                        : Container(),
                  ),
                )
              : Container(),
          SizedBox(
            height: 5,
          ),
          isNavigationStarted
              ? FloatingActionButton(
                  heroTag: "start",
                  backgroundColor: Colors.white,
                  onPressed: () {
                    // _showStepsBottomSheet(context);
                    setState(() {
                      isNavigationStarted = false;
                    });
                  },
                  child: const Icon(Icons.stop),
                )
              : FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    // _showStepsBottomSheet(context);
                    setState(() {
                      isNavigationStarted = true;
                    });
                    _startModelTimer();
                    _startMapTimer();
                  },
                  child: const Icon(Icons.start),
                ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            heroTag: "route",
            backgroundColor: Colors.white,
            onPressed: () {
              _showBottomSheet(context);
            },
            child: const Icon(Icons.route),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              // expandedHeight: 350.h,
              expandedHeight: 310.h,
              flexibleSpace: FlexibleSpaceBar(
                // title: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         isAppBarExpanded ? "" : "Navigation",
                //         style:
                //             const TextStyle(color: Colors.black, fontSize: 14),
                //       ),
                //       // Icon(isAppBarExpanded
                //       //     ? Icons.arrow_upward
                //       //     : Icons.arrow_downward),
                //     ],
                //   ),
                // ),
                background: Align(
                  alignment: Alignment.topRight,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: const EdgeInsets.all(0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row(children: [
                          //   const Icon(Icons.arrow_back_ios),
                          //   SizedBox(height: 8.h),
                          //   Text(
                          //     'Navigation',
                          //     style: TextStyle(
                          //       color: const Color(0xff0F0F0F),
                          //       fontSize: 16.sp,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   )
                          // ]),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              SizedBox(height: 8.h),
                              const Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    '|',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '|',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '|',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Icon(Icons.location_on)
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        TypeAheadField(
                                          getImmediateSuggestions: true,
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            controller: fromController,
                                            onChanged: (query) {
                                              _getSuggestions(query);
                                            },
                                            decoration: Styles.kInputDecoration
                                                .copyWith(
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  fromController.text = "";
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              hintText: "Starting Point",
                                              hintStyle: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff9A9A9A),
                                              ),
                                            ),
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            if (pattern.isEmpty) return [];
                                            return _suggestions;
                                          },
                                          itemBuilder: (context, suggestion) {
                                           
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.pin_drop,
                                                color: Colors.grey,
                                              ),
                                              title: Text(
                                                  suggestion["properties"]
                                                      ["label"] as String),
                                              // title: Text(
                                              //     suggestion["display_name"]
                                              //         as String),
                                            );
                                          },
                                          noItemsFoundBuilder: (context) {
                                            return const ListTile(
                                              leading: Icon(
                                                Icons.pin_drop,
                                                color: Colors.grey,
                                              ),
                                              title:
                                                  Text('No Suggestions Found'),
                                            );
                                          },
                                          onSuggestionSelected:
                                              (suggestion) async {
                                         
                                            setState(() {
                                              fromLat = suggestion["geometry"]
                                                  ["coordinates"][1];
                                              fromLong = suggestion["geometry"]
                                                  ["coordinates"][0];
                                              from =
                                                  LatLng(fromLat!, fromLong!);
                                              fromController.text =
                                                  suggestion["properties"]
                                                      ["label"];
                                              // fromLat = double.parse(
                                              //     suggestion["lat"]);

                                              // fromLong = double.parse(
                                              //     suggestion["lon"]);

                                              // from =
                                              //     LatLng(fromLat!, fromLong!);
                                              // fromController.text =
                                              //     suggestion["display_name"];
                                            });
                                          
                                            if (fromLat != null &&
                                                fromLong != null &&
                                                toLat != null &&
                                                toLong != null) {
                                              navigate(fromLat, fromLong, toLat,
                                                  toLong);
                                            }
                                          },
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (fromLat != null &&
                                                fromLong != null &&
                                                toLat != null &&
                                                toLong != null) {
                                              setState(() {
                                                fromLatLong =
                                                    LatLng(fromLat!, fromLong!);
                                                from = to;
                                                to = fromLatLong;
                                                fromLatSwap = fromLat;
                                                fromLongSwap = fromLong;
                                                fromLat = toLat;
                                                fromLong = toLong;
                                                toLat = fromLatSwap;
                                                toLong = fromLongSwap;
                                                String fromText =
                                                    fromController.text;
                                                fromController.text =
                                                    toController.text;
                                                toController.text = fromText;
                                              });
                                              navigate(fromLat, fromLong, toLat,
                                                  toLong);
                                            }
                                          },
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.south_sharp,
                                              ),
                                              // SizedBox(
                                              //   width: 3,
                                              // ),
                                              Icon(
                                                Icons.north_sharp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        TypeAheadField(
                                            getImmediateSuggestions: true,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                              controller: toController,
                                              onChanged: (query) {
                                                _getSuggestions(query);
                                              },
                                              decoration: Styles
                                                  .kInputDecoration
                                                  .copyWith(
                                                suffixIcon: GestureDetector(
                                                  onTap: () {
                                                    toController.text = "";
                                                  },
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                hintText: "Ending Point",
                                                hintStyle: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff9A9A9A),
                                                ),
                                              ),
                                            ),
                                            suggestionsCallback:
                                                (pattern) async {
                                              if (pattern.isEmpty) return [];
                                              return _suggestions;
                                            },
                                            itemBuilder: (context, suggestion) {
                                              return ListTile(
                                                leading: const Icon(
                                                  Icons.pin_drop,
                                                  color: Colors.grey,
                                                ),
                                                title: Text(
                                                    suggestion["properties"]
                                                        ["label"] as String),
                                                // title: Text(
                                                //     suggestion["display_name"]
                                                //         as String),
                                              );
                                            },
                                            noItemsFoundBuilder: (context) {
                                              return const ListTile(
                                                leading: Icon(
                                                  Icons.pin_drop,
                                                  color: Colors.grey,
                                                ),
                                                title: Text(
                                                    'No Suggestions Found'),
                                              );
                                            },
                                            onSuggestionSelected:
                                                (suggestion) async {
                                              // _controller.text = suggestion as String;
                                            
                                              setState(() {
                                                toLat = suggestion["geometry"]
                                                    ["coordinates"][1];
                                                toLong = suggestion["geometry"]
                                                    ["coordinates"][0];
                                                to = LatLng(toLat!, toLong!);
                                                toController.text =
                                                    suggestion["properties"]
                                                        ["label"];
                                                // toLat = double.parse(
                                                //     suggestion["lat"]);

                                                // toLong = double.parse(
                                                //     suggestion["lon"]);

                                                // to = LatLng(toLat!, toLong!);
                                                // toController.text =
                                                //     suggestion["display_name"];
                                                // _showBottomSheet(context);
                                              });

                                             

                                              // var url = Uri.parse(
                                              // 'http://69.143.1.168:5000/route/v1/driving-car/$fromLong,$fromLat;$toLong,$toLat?alternatives=3&steps=true&geometries=geojson');
                                              navigate(fromLat, fromLong, toLat,
                                                  toLong);
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.h),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 35.w,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xffF5F5F5))),
                                    //icon: const Icon(Icons.directions),
                                    onPressed: () {},
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        'Add Route',
                                        style: TextStyle(
                                            color: Color(0xff9A9A9A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 55.h,
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18.w,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              selectedProfile == 0
                                                  ? Colors.black
                                                  : Colors.white),
                                    ),
                                    //icon: const Icon(Icons.directions),
                                    onPressed: () {
                                      // getRoute();
                                      setState(() {
                                        selectedProfile = 0;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(5.w),
                                      child: Icon(
                                        Icons.directions_car,
                                        // color: Colors.black,
                                        color: selectedProfile == 0
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.h),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              selectedProfile == 1
                                                  ? Colors.black
                                                  : Colors.white),
                                    ),
                                    //icon: const Icon(Icons.directions),
                                    onPressed: () {
                                      // getRoute();
                                      setState(() {
                                        selectedProfile = 1;
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          FontAwesomeIcons.walking,
                                          size: 25.0,
                                          // color: Colors.black,
                                          color: selectedProfile == 1
                                              ? Colors.white
                                              : Colors.black,
                                        )),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              selectedProfile == 2
                                                  ? Colors.black
                                                  : Colors.white),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        selectedProfile = 2;
                                      });
                                      var url = Uri.parse(
                                          'http://69.143.1.168:5000/route/v1/driving-car/$fromLat,$fromLong;$toLat,$toLong?alternatives=3&steps=true&geometries=geojson');
                                      var response = await http.get(url);

                                      setState(() {
                                        var ruter =
                                            jsonDecode(response.body)['routes']
                                                [0]['geometry']['coordinates'];


                                        for (int i = 0; i < ruter.length; i++) {
                                          var reep = ruter[i].toString();
                                          reep = reep.replaceAll("[", "");
                                          reep = reep.replaceAll("]", "");
                                          var lat1 = reep.split(',');
                                          var long1 = reep.split(",");
                                          points.add(LatLng(
                                              double.parse(lat1[1]),
                                              double.parse(long1[0])));
                                        }
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.directions_railway,
                                          color: selectedProfile == 2
                                              ? Colors.white
                                              : Colors.black,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: Visibility(
                // visible: isVisible,
                visible: true,
                // child: routePoints.isEmpty
                // ? const Center(child: CircularProgressIndicator())
                // : _isLoading
                child: routePoints.isEmpty
                    ? _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: Text(
                                "Please insert both starting and ending points"),
                          )
                    : _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            options: MapOptions(
                              onTap:
                                  // use [isPairly] to switch between [from] and [to]
                                  (_, point) {
                                // if (isPairly) {
                                //   to = point;
                                // } else {
                                //   from = point;
                                // }
                                // isPairly = !isPairly;
                                // setState(() {});
                                // getRoute();
                              },
                              center: routePoints[center.toInt()],
                              zoom: 14,
                            ),
                            nonRotatedChildren: [
                              RichAttributionWidget(
                                animationConfig: const ScaleRAWA(),
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                    onTap: () => launchUrl(
                                      Uri.parse(
                                        'https://openstreetmap.org/copyright',
                                      ),
                                    ),
                                  ),
                                  TextSourceAttribution(
                                    'Danien Mesfin',
                                    onTap: () => launchUrl(
                                      Uri.parse(
                                          'mailto:danielmesfin331@gmail.com1'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                              ),

                              /// [PolylineLayer] draw the route between two coordinates [from] and [to]
                              PolylineLayer(
                                polylineCulling: false,
                                polylines: [
                                  Polyline(
                                    points: routePoints,
                                    strokeWidth: 4.0,
                                    color: Colors.red,
                                  ),
                                ],
                              ),

                              /// [MarkerLayer] draw the marker on the map
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: from,
                                    child: const Icon(
                                      Icons.pin_drop,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: to,
                                    child: const Icon(
                                      Icons.pin_drop,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (points.isNotEmpty)
                                    Marker(
                                      rotate: true,
                                      width: 80.0,
                                      height: 30.0,
                                      point: points[math.max(
                                          0, (points.length / 2).floor())],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              '${distance.toStringAsFixed(2)} m',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
