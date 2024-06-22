import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leaflet_map_app1/Controller/userController.dart';
import 'package:leaflet_map_app1/constants/styles.dart';
import 'package:leaflet_map_app1/screens/forget_password.dart';
import 'package:leaflet_map_app1/widgets/application_name.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'register_screen.dart';
import 'search_screen.dart';
import 'package:leaflet_map_app1/widgets/siginSignupButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogInPage extends StatefulWidget {
  static const id = 'login-page';
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isLoading = false;
  TextEditingController emalimEditingController = TextEditingController();
  TextEditingController passworEditingController = TextEditingController();

  bool isLoading = false;

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
                    'Sign in using your credentials!',
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
                SizedBox(height: 20.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email Address",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    EmailValidationTextField(
                      whenTextFieldEmpty: "Please enter  email",
                      validatorMassage: "Please enter valid email",
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      textEditingController: emalimEditingController,
                      onChanged: (value) {
                        emalimEditingController.text = value;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password",
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
                        passworEditingController.text = value; //
                      },
                      passTextEditingController: passworEditingController,
                      passwordMaxLength: 10,
                      passwordMinLength: 5,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                        value: true,
                        activeColor: const Color(0xff000000),
                        onChanged: (value) {}),
                    const Text(
                      'Remember account',
                      style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                    Container(),
                  ],
                ),
                SizedBox(height: 15.h),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password? Click here to reset',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                _isLoading
                    // ? SiginSiginupButton(
                    //     buttonLabel: "Sigin In", buttonPressed: null)
                    ? Transform.scale(
                        scale: 0.2,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : SiginSiginupButton(
                        buttonLabel: "Sigin In",
                        buttonPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          dynamic response = await API().login(
                            emalimEditingController.text,
                            passworEditingController.text,
                            context,
                          );

                          if (response["token"] != null) {
                            prefs.setString("token", response["token"]);
                            Map<String, dynamic> user = response["user"];
                            String jsonUser = jsonEncode(user);
                            await prefs.setString('user', jsonUser);
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapScreen(),
                              ),
                            );
                          }
                        },
                      ),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    'Or',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff000000),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                AbsorbPointer(
                  absorbing: isLoading,
                  child: TextButton.icon(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      dynamic response = await API().signInWithGoogleA(context);

                      if (response["token"] != null) {
                        prefs.setString("token", response["token"]);
                        Map<String, dynamic> user = response["user"];
                        String jsonUser = jsonEncode(user);
                        await prefs.setString('user', jsonUser);
                        String jsonStringFromPrefs = prefs.getString('user')!;
                        var jsonObjectFromPrefs =
                            jsonDecode(jsonStringFromPrefs);
                    
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      FontAwesomeIcons.google,
                      size: 20,
                      color: Colors.black,
                    ),
                    label: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Text(
                        "Google",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigUpPage(),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Don’t have an account? Sign Up',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
