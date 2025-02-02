import 'package:daimond_host_provider/extension/sized_box_extension.dart';
import 'package:daimond_host_provider/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:daimond_host_provider/screens/sign_in_screen.dart';
import 'package:daimond_host_provider/widgets/reused_textform_field.dart';
import 'package:daimond_host_provider/widgets/reused_phone_number_widget.dart';
import 'package:daimond_host_provider/constants/styles.dart';
import 'package:daimond_host_provider/constants/colors.dart';
import 'package:daimond_host_provider/extension/sized_box_extension.dart';
import 'package:daimond_host_provider/widgets/reused_elevated_button.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../backend/login_method.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../localization/language_constants.dart';
import '../utils/global_methods.dart';
import '../widgets/language_translator_widget.dart';
import '../widgets/reused_elevated_button.dart';
import '../widgets/reused_phone_number_widget.dart';
import '../widgets/reused_textform_field.dart';
import 'forgot_password.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  String initialCountry = 'SA';
  PhoneNumber number = PhoneNumber(isoCode: 'SA');
  PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _phoneNumber;
  final LoginMethod _loginMethod = LoginMethod();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: kPurpleColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const LanguageDialogWidget();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                40.kH,
                Text(
                  getTranslated(context, "Login"),
                  style: kPrimaryStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2.0,
                                color: _currentIndex == 0
                                    ? kPurpleColor
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Text(
                            getTranslated(context, 'Email & Password'),
                            textAlign: TextAlign.center,
                            style: kSecondaryStyle,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2.0,
                                color: _currentIndex == 1
                                    ? kPurpleColor
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Text(
                            getTranslated(context, 'Phone Number'),
                            textAlign: TextAlign.center,
                            style: kSecondaryStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                20.kH,
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      Column(
                        children: [
                          ReusedTextFormField(
                            hintText: getTranslated(context, 'Email'),
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return getTranslated(
                                    context, 'Please enter your email');
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return getTranslated(context,
                                    'Please enter a valid email address');
                              }
                              return null;
                            },
                          ),
                          20.kH,
                          ReusedTextFormField(
                            controller: _passwordController,
                            hintText: getTranslated(context, 'Password'),
                            prefixIcon: LineAwesome.user_lock_solid,
                            obscureText: true,
                            validator: (value) {
                              if (_currentIndex == 0) {
                                if (value == null || value.isEmpty) {
                                  return getTranslated(
                                      context, 'Please enter your password');
                                }
                              }
                              return null;
                            },
                          ),
                          20.kH,
                          CustomButton(
                            text: getTranslated(context, 'Login'),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                _loginMethod.loginWithEmail(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  context: context,
                                );
                              }
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              getTranslated(context, 'Forgot Password?'),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Phone Number Form
                      Column(
                        children: [
                          ReusedPhoneNumberField(
                            onPhoneNumberChanged: (phone) {
                              setState(() {
                                _phoneNumber = phone;
                              });
                            },
                            validator: (phone) {
                              if (_currentIndex == 1) {
                                if (phone == null || phone.number.isEmpty) {
                                  return getTranslated(context,
                                      'Please enter a valid phone number');
                                }
                              }
                              return null;
                            },
                          ),
                          20.kH,
                          CustomButton(
                            text: getTranslated(
                                context, 'Login through phone number'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _loginMethod.loginWithPhone(
                                  phoneNumber: _phoneNumber!,
                                  context: context,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(getTranslated(context, "Are you new here? ")),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()),
                        );
                      },
                      child: Text(
                        getTranslated(context, "Sign in"),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
