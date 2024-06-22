
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leaflet_map_app1/Controller/userController.dart';
import 'package:leaflet_map_app1/constants/styles.dart';
import 'package:leaflet_map_app1/screens/login_screen.dart';
import 'package:leaflet_map_app1/widgets/application_name.dart';
import 'package:flutter/material.dart';
import 'package:validation_textformfield/validation_textformfield.dart';
import 'package:leaflet_map_app1/widgets/siginSignupButton.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ForgotPasswordPage> {
  bool _isLoading = false;

  var statusCode = 0;
  bool isLoading = false;
  var errorMesssage;

  TextEditingController enteryouremail = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confrimationCode = TextEditingController();

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
                    'Forget Password',
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
                      "Enter Your Email",
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
                      textEditingController: enteryouremail,
                      onChanged: (value) {
                        enteryouremail.text = value;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                statusCode == 200
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verification code",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff000000),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          TextField(
                            decoration:
                                Styles.kInputDecoration.copyWith(hintText: ""),
                            obscureText: false,
                            scrollPadding: EdgeInsets.only(left: 60),
                            onChanged: (value) {
                              confrimationCode.text = value; //
                            },
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 10.h),
                statusCode == 200
                    ? Column(
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
                              newPassword.text = value; //
                            },
                            passTextEditingController: newPassword,
                            passwordMaxLength: 10,
                            passwordMinLength: 5,
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 30.h),
                statusCode == 200
                    ? SiginSiginupButton(
                        buttonLabel: "Reset",
                        buttonPressed: () async {
                          final res = await API().setNewPassword(
                              newPassword.text,
                              enteryouremail.text,
                              confrimationCode.text,
                              context);
                          if (res == 200) {
                            setState(() {
                              statusCode = 200;
                            });
                            // ignore: use_build_context_synchronously
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return LogInPage();
                              },
                            ));
                          } else {}
                        },
                      )
                    : SiginSiginupButton(
                        buttonLabel: "Send",
                        buttonPressed: () async {
                          final res = await API()
                              .forgotPassword(enteryouremail.text, context);

                          if (res == 200) {
                            setState(() {
                              statusCode = 200;
                            });
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
