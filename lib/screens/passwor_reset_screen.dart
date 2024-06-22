import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leaflet_map_app1/constants/styles.dart';
import 'package:leaflet_map_app1/widgets/application_name.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'search_screen.dart';
import 'package:leaflet_map_app1/widgets/siginSignupButton.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _isLoading = false;
  var token;

  var userId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoggedInUser();
  }

  void checkLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    String jsonStringFromPrefs = prefs.getString('user')!;
    final jsonObjectFromPrefs = jsonDecode(jsonStringFromPrefs);
    userId = jsonObjectFromPrefs["id"];
   
  }

  Future<int> changePassword(String currentPassword, String newPassword) async {
    String url = 'http://69.243.101.217:3000/users/change-password/$userId';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    Map<String, String> body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPsswordEditingController.text
    };
    String jsonBody = jsonEncode(body);
    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);
    return response.statusCode;
  }

  bool isLoading = false;
  var errorMesssage;

  TextEditingController currentPsswordEditingController =
      TextEditingController();
  TextEditingController newPsswordEditingController = TextEditingController();

  TextEditingController confirmPsswordEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: 900.h,
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
            child: ListView(
              children: [
                SizedBox(height: 100.h),
                const ApplicationName(),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    'Welcome Back',
                    textDirection: null,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                const Center(
                  child: Text(
                    'Reset Password',
                    textDirection: null,
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                const Divider(
                  color: Color.fromARGB(255, 97, 95, 97),
                  height: 1.5,
                ),
                isLoading
                    ? const LinearProgressIndicator(
                        color: Colors.black,
                        backgroundColor: Colors.amberAccent,
                      )
                    : const SizedBox(),
                errorMesssage != null && !isLoading
                    ? Text(
                        errorMesssage,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      )
                    : const SizedBox(),
                SizedBox(height: 20.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Password",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    PassWordValidationTextFiled(
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      lineIndicator: false,
                      passwordMinError: "Must be more than 5 charater",
                      hasPasswordEmpty: "Password is Empty",
                      passwordMaxError: "Password to long",
                      passWordUpperCaseError:
                          "At least one Uppercase (Capital)lette",
                      passWordDigitsCaseError: "at least one digit",
                      passwordLowercaseError:
                          "At least one lowercase character",
                      passWordSpecialCharacters:
                          "At least one Special Characters",
                      obscureText: true,
                      scrollPadding: EdgeInsets.only(left: 60),
                      onChanged: (value) {
                        currentPsswordEditingController.text = value; //
                      },
                      passTextEditingController:
                          currentPsswordEditingController,
                      passwordMaxLength: 10,
                      passwordMinLength: 5,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Password",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    PassWordValidationTextFiled(
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      lineIndicator: false,
                      passwordMinError: "Must be more than 5 charater",
                      hasPasswordEmpty: "Password is Empty",
                      passwordMaxError: "Password to long",
                      passWordUpperCaseError:
                          "At least one Uppercase (Capital)lette",
                      passWordDigitsCaseError: "at least one digit",
                      passwordLowercaseError:
                          "At least one lowercase character",
                      passWordSpecialCharacters:
                          "At least one Special Characters",
                      obscureText: true,
                      scrollPadding: EdgeInsets.only(left: 60),
                      onChanged: (value) {
                        newPsswordEditingController.text = value; //
                      },
                      passTextEditingController: newPsswordEditingController,
                      passwordMaxLength: 10,
                      passwordMinLength: 5,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    ConfirmPassWordValidationTextFromField(
                      obscureText: true,
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      scrollPadding: EdgeInsets.only(left: 60),
                      onChanged: (value) {
                        confirmPsswordEditingController.text = value;
                      },
                      whenTextFieldEmpty: "Empty",
                      validatorMassage: "Password not Match",
                      confirmtextEditingController:
                          confirmPsswordEditingController,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(height: 30.h),
                _isLoading
                    // ? SiginSiginupButton(
                    //     buttonLabel: "Sigin In", buttonPressed: null)
                    ? Transform.scale(
                        scale: 0.2,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          // backgroundColor: Colors.grey[300],
                          // valueColor:
                          // AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : SiginSiginupButton(
                        buttonLabel: "Reset",
                        buttonPressed: () async {
                        
                          final res = await changePassword(
                              currentPsswordEditingController.text,
                              newPsswordEditingController.text);
                          if (res == 201) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return MapScreen();
                              },
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You have successfully changed password'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('try again'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
