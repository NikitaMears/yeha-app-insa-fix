import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leaflet_map_app1/Controller/userController.dart';
import 'package:leaflet_map_app1/constants/styles.dart';
import 'package:leaflet_map_app1/screens/search_screen.dart';
import 'package:leaflet_map_app1/widgets/application_name.dart';
import 'package:flutter/material.dart';
import 'package:leaflet_map_app1/widgets/message_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'login_screen.dart';
import 'package:leaflet_map_app1/widgets/siginSignupButton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SigUpPage extends StatefulWidget {
  static const id = 'login-page';
  const SigUpPage({super.key});

  @override
  State<SigUpPage> createState() => _SigUpPage();
}

class _SigUpPage extends State<SigUpPage> {
  TextEditingController firstNameEditingController = TextEditingController();
  TextEditingController lastNameEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController emailmEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController passwordConfirEditing = TextEditingController();
  TextEditingController passwordConfirEditingController =
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
                SizedBox(height: 30.h),
                const ApplicationName(),
                SizedBox(height: 15.h),
                Center(
                  child: Text(
                    'Welcome',
                    textDirection: null,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    'Create an account to use our services',
                    textDirection: null,
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
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
                      "First Name",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    TextField(
                      onChanged: (vlue) {
                        firstNameEditingController.text = vlue;
                      },
                      keyboardType: TextInputType.text,
                      decoration: Styles.kInputDecoration
                          .copyWith(hintText: "", errorText: ""),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Name",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    TextField(
                      onChanged: (vlue) {
                        lastNameEditingController.text = vlue;
                      },
                      keyboardType: TextInputType.text,
                      decoration: Styles.kInputDecoration
                          .copyWith(hintText: "", errorText: ""),
                      textAlign: TextAlign.start,
                    ),
                  ],
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
                      keyboardType: TextInputType.emailAddress,
                      whenTextFieldEmpty: "Please enter  email",
                      validatorMassage: "Please enter valid email",
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      textEditingController: emailmEditingController,
                      onChanged: (value) {
                        emailmEditingController.text = value;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    TextField(
                      onChanged: (vlue) {
                        phoneNumberEditingController.text = vlue;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: Styles.kInputDecoration
                          .copyWith(hintText: "", errorText: ""),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
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
                        passwordEditingController.text = value; //
                      },
                      passTextEditingController: passwordEditingController,
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
                        color: const Color(0xff000000),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    ConfirmPassWordValidationTextFromField(
                      obscureText: true,
                      decoration:
                          Styles.kInputDecoration.copyWith(hintText: ""),
                      scrollPadding: EdgeInsets.only(left: 60),
                      onChanged: (value) {
                        passwordConfirEditing.text = value;
                      },
                      whenTextFieldEmpty: "Empty",
                      validatorMassage: "Password not Match",
                      confirmtextEditingController: passwordConfirEditing,
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                SiginSiginupButton(
                  buttonLabel: "Sigin up",
                  buttonPressed: () async {
                    dynamic response = await API().signup(
                        firstNameEditingController.text,
                        lastNameEditingController.text,
                        emailmEditingController.text,
                        phoneNumberEditingController.text,
                        passwordEditingController.text,
                        context);

                    if (response["user"] != null) {
                      MessageDisplay.showMessage("User created successfully!!",
                          context, Colors.grey, "Error");

                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogInPage(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 15.h),
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
                TextButton.icon(
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
                    dynamic response = await API().signInWithGoogle(context);

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
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogInPage(),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
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
