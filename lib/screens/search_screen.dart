// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leaflet_map_app1/screens/login_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leaflet_map_app1/screens/myplace.dart';
import 'package:leaflet_map_app1/screens/passwor_reset_screen.dart';
import 'package:leaflet_map_app1/widgets/message_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/styles.dart';
import '../widgets/bottomSheetItem.dart';
import 'package:location/location.dart';
import '../Controller/userController.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  //Map Controller
  MapController mapController = MapController();
  final TextEditingController _controller = TextEditingController();
  //List Of Variables
  List<Marker> _markers = [];
  List<dynamic> _suggestions = [];
  double? initialLat;
  double? initialLong;
  double? searchedLat;
  double? searchedLong;
  Marker? marker;
  bool selected = false;

  bool _isLoggedIn = false;
  Map<String, dynamic>? jsonObjectFromPrefs;
  late final prefs;

  final String? api_key = dotenv.env["API_KEY"];
  final String? base_url = dotenv.env["BASE_URL"];

  Future<void> checkTokenExpiration() async {
    // setState(() async {
    prefs = await SharedPreferences.getInstance();
    // });
    // final expirationTime = prefs.getInt('token_expiration');
    // if (prefs.getInt('token_expiration') != null) {
    //   final now = DateTime.now().millisecondsSinceEpoch;
    //   if (now < prefs.getInt('token_expiration')!) {
    //     // Log out the user
    //     setState(() {
    //       _isLoggedIn = true;
    //     });
    //   }
    // }
    if (prefs.getString("token") != null) {
      setState(() {
        _isLoggedIn = true;
      });
      String jsonStringFromPrefs = prefs.getString('user')!;
      jsonObjectFromPrefs = jsonDecode(jsonStringFromPrefs);

    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  List<LatLng> routpoints = [
    const LatLng(8.697458, 39.06208),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    checkTokenExpiration();
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
      // markerLat = initialLat;
      // markerLong = initialLong;
      // getLocationName(initialLat!, initialLong!);
      routpoints.add(LatLng(initialLat!, initialLong!));
    });
  }

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

  void _showProfileBottomSheet(BuildContext context) {
    checkTokenExpiration();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          Text(
                            "Ethio Maps",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  !_isLoggedIn
                      ? Container(
                          width: double.infinity,
                          child: Card(
                            child: Column(
                              children: [
                                Text("You loggedin as a guest"),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const LogInPage();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                            children: [
                              Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Padding(
                                        padding: EdgeInsets.all(0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.person_2_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${jsonObjectFromPrefs!["firstName"]} ${jsonObjectFromPrefs!["lastName"]}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      subtitle: Text(
                                        jsonObjectFromPrefs!["email"],
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        prefs.remove("token");
                                        prefs.remove("user");
                                        jsonObjectFromPrefs = null;
                                        setState(() {
                                          _isLoggedIn = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Column(
                                  children: [
                                    const ListTile(
                                      leading: Icon(
                                        Icons.person_2_outlined,
                                      ),
                                      title: Text(
                                        "Your profile",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return ResetPasswordPage();
                                          },
                                        ));
                                      },
                                      leading: const Icon(
                                        Icons.password_outlined,
                                      ),
                                      title: const Text(
                                        "Reset password",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const ListTile(
                                      leading: Icon(
                                        Icons.save_outlined,
                                      ),
                                      title: Text(
                                        "Saved",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () async {
                                        dynamic response =
                                            await API().getMyplace(
                                          jsonObjectFromPrefs!["id"],
                                          context,
                                        );
                                       
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return MyPlace(
                                              placelist: response,
                                            );
                                          },
                                        ));
                                      },
                                      leading: const Icon(
                                        Icons.dataset_outlined,
                                      ),
                                      title: const Text(
                                        "My Place On EthioMaps",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const ListTile(
                                      leading: Icon(
                                        Icons.settings_outlined,
                                      ),
                                      title: Text(
                                        "Settings",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const ListTile(
                                      leading: Icon(
                                        Icons.help_outline,
                                      ),
                                      title: Text(
                                        "Help and Feedback",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, String label) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "images/home.PNG",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      label,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BottomMeauItem(
                        lebel: "Direction",
                        iconData: Icons.directions,
                        buttonCallBack: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return NavigationScreen(
                                  fromLat: initialLat,
                                  toLat: searchedLat,
                                  fromLong: initialLong,
                                  toLong: searchedLong,
                                );
                              },
                            ),
                          );
                        },
                        backgoundColor: const Color(0xff1211FF),
                        textColor: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BottomMeauItem(
                        lebel: "Call",
                        iconData: Icons.call,
                        buttonCallBack: () {},
                        backgoundColor:
                            const Color.fromARGB(255, 229, 226, 226),
                        textColor: Colors.black,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BottomMeauItem(
                        lebel: "Save",
                        iconData: Icons.save,
                        buttonCallBack: () {},
                        backgoundColor:
                            const Color.fromARGB(255, 229, 226, 226),
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  initialLat == null || initialLong == null
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.black,
                        ))
                      : FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            onTap: (tapPosition, point) {
                            
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Add your place",
                                      textAlign: TextAlign.center,
                                    ),
                                    alignment: Alignment.center,
                                    content: PopUpContent(
                                        lat: point.latitude,
                                        lon: point.longitude,
                                        id: jsonObjectFromPrefs != null
                                            ? jsonObjectFromPrefs!["id"]
                                            : null),
                                  );
                                },
                              );
                            },
                            center: LatLng(initialLat!, initialLong!),
                            // onPositionChanged: (position, hasGesture) {},
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
                                Marker(
                                  // point: LatLng(initialLat!, initialLong!),
                                  point: searchedLat == null ||
                                          searchedLong == null
                                      ? LatLng(initialLat!, initialLong!)
                                      : LatLng(searchedLat!, searchedLong!),
                                  child: const Icon(
                                    Icons.pin_drop,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: TypeAheadField(
                      getImmediateSuggestions: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _controller,
                        onChanged: (query) {
                          _getSuggestions(query);
                        },
                        decoration: Styles.kInputDecoration.copyWith(
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _controller.text = "";
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showProfileBottomSheet(context);
                                },
                                // child: const Icon(
                                //   Icons.person_2_outlined,
                                //   size: 30,
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    // radius: 5,
                                    backgroundColor: Colors.blue,
                                    child: const Icon(
                                      Icons.person_2_outlined,
                                      // size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                          title:
                              Text(suggestion["properties"]["label"] as String),
                          // title: Text(suggestion["display_name"] as String),
                        );
                      },
                      noItemsFoundBuilder: (context) {
                        return const ListTile(
                          leading: Icon(
                            Icons.pin_drop,
                            color: Colors.grey,
                          ),
                          title: Text('No Suggestions Found'),
                        );
                      },
                      onSuggestionSelected: (suggestion) async {
                        mapController.move(
                          LatLng(suggestion["geometry"]["coordinates"][1],
                              suggestion["geometry"]["coordinates"][0]),
                          // LatLng(double.parse(suggestion["lat"]),
                          // double.parse(suggestion["lon"])),
                          15,
                        );
                        _showBottomSheet(
                            context, suggestion["properties"]["label"]);
                        // _showBottomSheet(context, suggestion["display_name"]);

                        setState(
                          () {
                            // initialLat =
                            //     suggestion["geometry"]["coordinates"][1];
                            // initialLong =
                            //     suggestion["geometry"]["coordinates"][0];
                            _controller.text =
                                suggestion["properties"]["label"];
                            searchedLat =
                                suggestion["geometry"]["coordinates"][1];
                            searchedLong =
                                suggestion["geometry"]["coordinates"][0];
                            // initialLat = double.parse(suggestion["lat"]);
                            // initialLong = double.parse(suggestion["lon"]);
                            // searchedLat = double.parse(suggestion["lat"]);
                            // searchedLong = double.parse(suggestion["lon"]);
                            // _controller.text = suggestion["display_name"];

                          
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const NavigationScreen();
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.directions, size: 38),
                ),
              ],
            ),
          );
        });
  }

  Drawer showDrawer(_isLoggedIn) {
    return Drawer(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF2A29CC),
            title: const Text(
              "Your Dash Bord",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.clear();
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LogInPage();
                      },
                    ),
                  );
                },
                child: const Icon(
                  Icons.logout_rounded,
                  size: 38,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 10.w,
              )
            ],
          ),
          body: Container(
            width: 30,
            child: Column(
              children: [
                Card(
                  elevation: 8,
                  child: SizedBox(
                    height: 200.h,
                    width: double.infinity,
                    child: Column(
                      children: [
                        !_isLoggedIn
                            ? const Center(
                                child: Text("Is already logged In"),
                              )
                            : const Text("")
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  child: SizedBox(
                    height: 200.h,
                    width: double.infinity,
                    child:
                        const Column(children: [Text("Pin your Product Here")]),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class PopUpContent extends StatelessWidget {
  final double lat;
  final double lon;
  final int? id;
  PopUpContent({super.key, required this.lat, required this.lon, this.id});
  final TextEditingController locationName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return id != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location Name:"),
                  TextField(
                    controller: locationName,
                    decoration: InputDecoration(
                        hintText: "Enter your place name",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [Text("Latitude: "), Text(lat.toString())],
              ),
              Row(
                children: [Text("Longitude: "), Text(lon.toString())],
              ),
              Row(
                children: [Text("User id: "), Text(id.toString())],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Navigator.pop(context);

                    
                      final response = await API()
                          .addPlace(locationName.text, lat, lon, id!, context);

                      if (response == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("you have added your place successfully,"),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "you have not added your place successfully,"),
                          ),
                        );
                        Navigator.pop(context);
                      }
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                ],
              )
            ],
          )
        : Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Text("You have to login first,"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return LogInPage();
                  },
                ));
              },
              child: Text("Login"),
            ),
          ]);
  }
}
