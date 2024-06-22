import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:leaflet_map_app1/widgets/message_display.dart';
import 'package:more_loading_gif/more_loading_gif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

var token;
var email;

class API {
  // static String userApi = "http://69.250.70.104:3000/";
  static String userApi = "https://apigateway.ethiomaps.com/usermanagement/";
  void loadingDialogue(context) {
    showDialog(
        useRootNavigator: false,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const MoreLoadingGif(
              type: MoreLoadingGifType.ripple,
            ),
          );
        });
  }

  Future<dynamic> signup(String firstName, String lastName, String email,
      String phoneNumber, String password, BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
        Uri.parse("https://apigateway.ethiomaps.com/usermanagement/signup"),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, String>{
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phoneNumber": phoneNumber,
            "password": password
          },
        ),
      );
      final responseData = jsonDecode(response.body);
      return responseData;
    } on TimeoutException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      //rethrow;
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      // dismissLoadingDialog(context);
      // // EasyLoading.dismiss();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

// login
  Future<dynamic> login(
      String email, String password, BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
        Uri.parse(
            "https://apigateway.ethiomaps.com/usermanagement/publicLogin"),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, String>{"email": email, "password": password},
        ),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 401) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage(
            "Invalid email or password", context, Colors.red, "Error");
      }
      if (response.statusCode == 500) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage(
            "Server Problem", context, Colors.red, "Error");
      }
      return responseData;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

// get user place
  Future<List<dynamic>> getMyplace(int id, BuildContext context) async {
    try {
      // loadingDialogue(context);
      final response = await http.get(
        Uri.parse("https://apigateway.ethiomaps.com/places/myPlaces/$id"),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
      );
      final responseData = jsonDecode(response.body);
     
      // if (response.statusCode == 401) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Invalid email or password", context, Colors.red, "Error");
      // }
      // if (response.statusCode == 500) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Server Problem", context, Colors.red, "Error");
      // }
      return responseData;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
    return [];
  }

// add places
  Future<dynamic> addPlace(String locationName, double lat, double lon, int id,
      BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
        Uri.parse("https://apigateway.ethiomaps.com/places/places"),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "userId": id,
            "coordinates": [lat, lon],
            "properties": {
              "id": "node/11034209868",
              "gid": "openstreetmap:venue:node/11034209866",
              "name": locationName,
              "label": "Arat Kilo, Addis Ababa, Ethiopia",
              "layer": "venue",
              "county": "Addis Ababa Zone 1",
              "region": "Addis Ababa",
              "source": "openstreetmap",
              "country": "Ethiopia",
              "accuracy": "point",
              "addendum": {
                "osm": {"operator": "Addis Ababa Bus Service Enterprise"}
              }
            }
          },
        ),
      );
      final responseData = jsonDecode(response.body);
   
      // if (response.statusCode == 401) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Invalid email or password", context, Colors.red, "Error");
      // }
      // if (response.statusCode == 500) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Server Problem", context, Colors.red, "Error");
      // }
      return response.statusCode;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

  // edit places
  Future<dynamic> editPlace(String locationName, double lat, double lon, int id,
      BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.put(
        Uri.parse("https://apigateway.ethiomaps.com/places/places/$id"),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "userId": 5,
            "coordinates": [lat, lon],
            "properties": {
              "id": "node/11034209868",
              "gid": "openstreetmap:venue:node/11034209866",
              "name": locationName,
              "label": "Arat Kilo, Addis Ababa, Ethiopia",
              "layer": "venue",
              "county": "Addis Ababa Zone 1",
              "region": "Addis Ababa",
              "source": "openstreetmap",
              "country": "Ethiopia",
              "accuracy": "point",
              "addendum": {
                "osm": {"operator": "Addis Ababa Bus Service Enterprise"}
              }
            }
          },
        ),
      );
      final responseData = jsonDecode(response.body);
  
      // if (response.statusCode == 401) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Invalid email or password", context, Colors.red, "Error");
      // }
      // if (response.statusCode == 500) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Server Problem", context, Colors.red, "Error");
      // }
      return response.statusCode;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

  // fetch places by id
  Future<dynamic> fetchPlace(int id, BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
          Uri.parse("https://apigateway.ethiomaps.com/places/myPlaces/$id"));
      final responseData = jsonDecode(response.body);
    
      // if (response.statusCode == 401) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Invalid email or password", context, Colors.red, "Error");
      // }
      // if (response.statusCode == 500) {
      //   Navigator.of(context).pop();
      //   MessageDisplay.showMessage(
      //       "Server Problem", context, Colors.red, "Error");
      // }
      return response.body;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

  //signup with Gmail :
  Future<dynamic> signUpWithGmail(String idToken, BuildContext context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
        Uri.parse('${userApi}signUpWithGmail'),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, String>{"idToken": idToken},
        ),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        MessageDisplay.showMessage(
            "User already exists", context, Colors.grey, "Error");
      }
     
      return responseData;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

  Future<dynamic> loginUpWithGmail(String idToken, context) async {
    try {
      loadingDialogue(context);
      final response = await http.post(
        Uri.parse('${userApi}loginWithGmail'),
        headers: <String, String>{
          'Content-type': 'application/json',
        },
        body: jsonEncode(
          <String, String>{"idToken": idToken},
        ),
      );
      final responseData = jsonDecode(response.body);
     
      if (response.statusCode == 404) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage("User not found. Please sign up first",
            context, Colors.red, "Error");
      }
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage("Well Come ${responseData["firstName"]}",
            context, Colors.green, "Error");
      }
      return responseData;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
  }

//sign up with facebook :
  Future<dynamic> signUpWithFacebook(String idToken) async {
    final response = await http.post(
      Uri.parse('${userApi}signUpWithFacebook'),
      headers: <String, String>{
        'Content-type': 'application/json',
      },
      body: jsonEncode(
        <String, String>{"idToken": idToken},
      ),
    );
    final responseData = jsonDecode(response.body);
    return UserData.fromJson(responseData);
  }

//sign up with facebook :
  Future<dynamic> loginUpWithFacebook(String idToken) async {
    final response = await http.post(
      Uri.parse('${userApi}loginWithFacebook'),
      headers: <String, String>{
        'Content-type': 'application/json',
      },
      body: jsonEncode(
        <String, String>{"idToken": idToken},
      ),
    );
    final responseData = jsonDecode(response.body);
    return UserData.fromJson(responseData);
  }

//1, These is the signin with gmail account functionality;
  Future<dynamic> signInWithGoogle(BuildContext context) async {
    dynamic response;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        String? idToken = await user.getIdToken();

        if (idToken!.isNotEmpty) {
          response = signUpWithGmail(idToken, context);

        } else {
        }
        return response;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

//2, These is the signin with facebook account functionality;
  Future<void> signUpWithFacebookDev() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FacebookAuth _facebookAuth = FacebookAuth.instance;
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        String? idToken = await user!.getIdToken();

     
        //  API().loginUpWithGmail(idToken!, context);
      } else {
      }
    } catch (e) {
    }
  }

//1, These is the signin with gmail account functionality;
  Future<dynamic> signInWithGoogleA(BuildContext context) async {
    dynamic response;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        String? idToken = await user.getIdToken();

        if (idToken!.isNotEmpty) {
          response = loginUpWithGmail(idToken, context);
        } else {
          // Handle the case where ID token retrieval failed
        }
        return response;
      } else {
        MessageDisplay.showMessage("Error", context, Colors.red, "Error");
        return null;
      }
    } on TimeoutException catch (e) {
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      Navigator.of(context).pop();
    } on SocketException catch (e) {
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      Navigator.of(context).pop();

      throw e.message;
    }
  }

//2, These is the signin with facebook account functionality;
  Future<void> signInWithFacebookDev() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FacebookAuth _facebookAuth = FacebookAuth.instance;
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        String? idToken = await user!.getIdToken();

      
        API().signUpWithFacebook(idToken!);
      } else {
      }
    } catch (e) {
    }
  }

  // forgot password
  var statusCode = 0;
  var userId;

  Future<int> forgotPassword(String newPassword, BuildContext context) async {
    try {
      loadingDialogue(context);
      String url =
          'https://apigateway.ethiomaps.com/usermanagement/forgotPassword';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      Map<String, String> body = {
        "email": newPassword,
      };
      String jsonBody = jsonEncode(body);
      final response =
          await http.post(Uri.parse(url), headers: headers, body: jsonBody);

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage("Verification code sent successfully",
            context, Colors.green, "Success");
      }
   
      return response.statusCode;
    } on TimeoutException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");

      throw e.message;
    }
    return 0;
  }

  Future<int> setNewPassword(String newPassword, String email,
      String verficationcode, BuildContext context) async {
    try {
      loadingDialogue(context);
      String url =
          'https://apigateway.ethiomaps.com/usermanagement/forgotPassword';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      Map<String, String> body = {
        "email": email,
        "verificationCode": verficationcode,
        "newPassword": newPassword
      };
      String jsonBody = jsonEncode(body);
      final response =
          await http.post(Uri.parse(url), headers: headers, body: jsonBody);

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        MessageDisplay.showMessage("Your password is rested successfully",
            context, Colors.green, "Success");
      }
  
      return response.statusCode;
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      MessageDisplay.showMessage(e.message!, context, Colors.red, "Error");
      throw e.message;
    }
    return 0;
  }
}
