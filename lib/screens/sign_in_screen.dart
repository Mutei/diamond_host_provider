import 'dart:math'; // Import for password generation
import 'package:auto_size_text/auto_size_text.dart';
import 'package:daimond_host_provider/extension/sized_box_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:icons_plus/icons_plus.dart'; // Import the icons_plus package

import '../backend/authentication_methods.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../localization/language_constants.dart';
import '../state_management/general_provider.dart';
import '../widgets/language_translator_widget.dart';
import '../widgets/reused_elevated_button.dart';
import '../widgets/reused_phone_number_widget.dart';
import '../widgets/reused_textform_field.dart';
import 'login_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _agentCodeController =
      TextEditingController(); // New Agent Code controller
  String? _phoneNumber;
  bool _acceptedTerms = false;

  final AuthenticationMethods _authMethods = AuthenticationMethods();

  Future<void> _launchTermsUrl() async {
    const url = 'https://www.diamondstel.com/Home/privacypolicy';
    try {
      if (await canLaunch(url)) {
        await launch(url, forceWebView: false);
        print('Launch successful');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  /// Function to generate a password that meets the required criteria:
  /// - At least 8 characters
  /// - Contains at least 1 uppercase letter
  /// - Contains at least 1 special character
  String generatePassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = '!@#\$&*~';

    final rand = Random.secure();
    String password = '';

    // Ensure at least 1 uppercase letter
    password += upperCase[rand.nextInt(upperCase.length)];

    // Ensure at least 1 lowercase letter
    password += lowerCase[rand.nextInt(lowerCase.length)];

    // Ensure at least 1 number
    password += numbers[rand.nextInt(numbers.length)];

    // Ensure at least 1 special character
    password += specialChars[rand.nextInt(specialChars.length)];

    // Fill the rest with random characters to make it at least 8 characters
    const allChars = upperCase + lowerCase + numbers + specialChars;
    int remainingLength = 8 - password.length;
    for (int i = 0; i < remainingLength; i++) {
      password += allChars[rand.nextInt(allChars.length)];
    }

    // Shuffle the characters to ensure randomness
    List<String> passwordChars = password.split('');
    passwordChars.shuffle(rand);
    return passwordChars.join();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(getTranslated(context, 'Sign in'), style: kPrimaryStyle),
                  20.kH,
                  ReusedTextFormField(
                    controller: _emailController,
                    hintText: getTranslated(context, 'Email'),
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return getTranslated(
                            context, 'Please enter your email');
                      }
                      // You can add more email validation if needed
                      return null;
                    },
                  ),
                  20.kH,
                  ReusedTextFormField(
                    controller: _passwordController,
                    hintText: getTranslated(context, 'Password'),
                    prefixIcon: LineAwesome.user_lock_solid,
                    obscureText: true,
                    onGeneratePassword: () {
                      setState(() {
                        String newPassword = generatePassword();
                        _passwordController.text = newPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return getTranslated(
                            context, 'Please enter your password');
                      }
                      if (!_authMethods.validatePassword(value)) {
                        return getTranslated(
                            context, 'Password does not meet criteria');
                      }
                      return null;
                    },
                  ),
                  20.kH,
                  ReusedPhoneNumberField(
                    onPhoneNumberChanged: (phone) {
                      setState(() {
                        _phoneNumber = phone;
                      });
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return getTranslated(
                            context, 'Please enter a valid phone number');
                      }
                      return null;
                    },
                  ),
                  20.kH,
                  ReusedTextFormField(
                    controller: _agentCodeController,
                    hintText: getTranslated(context, 'Agent Code'),
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    // No need for obscureText or onGeneratePassword here
                  ),
                  10.kH,
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value!;
                      });
                    },
                    title: RichText(
                      text: TextSpan(
                        text: getTranslated(context, 'I accept the '),
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                getTranslated(context, 'terms and conditions'),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchTermsUrl();
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomButton(
                    text: getTranslated(context, 'Sign in'),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (_formKey.currentState!.validate()) {
                        if (!_acceptedTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(getTranslated(context,
                                  'Please accept the terms and conditions')),
                            ),
                          );
                          return;
                        }

                        try {
                          await _authMethods.signUpWithEmailPhone(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            phone: _phoneNumber!,
                            acceptedTerms: _acceptedTerms,
                            agentCode: _agentCodeController.text
                                .trim(), // Pass Agent Code
                            context: context,
                          );
                          print('OTP sent for verification');
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(getTranslated(
                          //         context, 'OTP sent for verification')),
                          //   ),
                          // );
                        } catch (e) {
                          print('Sign-up failed: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  getTranslated(context, 'Sign-up failed: $e')),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  20.kH,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          getTranslated(context, "Already have an account? "),
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          getTranslated(context, "Login"),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
      ),
    );
  }
}

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:daimond_host_provider/extension/sized_box_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/gestures.dart';
// import 'package:icons_plus/icons_plus.dart'; // Import the icons_plus package
//
// import '../backend/authentication_methods.dart';
// import '../constants/colors.dart';
// import '../constants/styles.dart';
// import '../localization/language_constants.dart';
// import '../state_management/general_provider.dart';
// import '../widgets/language_translator_widget.dart';
// import '../widgets/reused_elevated_button.dart';
// import '../widgets/reused_phone_number_widget.dart';
// import '../widgets/reused_textform_field.dart';
// import 'login_screen.dart';
//
// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});
//
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _agentCodeController =
//       TextEditingController(); // New Agent Code controller
//   String? _phoneNumber;
//   bool _acceptedTerms = false;
//
//   final AuthenticationMethods _authMethods = AuthenticationMethods();
//
//   Future<void> _launchTermsUrl() async {
//     const url = 'https://www.diamondstel.com/Home/privacypolicy';
//     try {
//       bool launched = await launch(url, forceWebView: false);
//       print('Launch successful: $launched');
//     } catch (e) {
//       print('Error launching maps: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.language, color: kPurpleColor),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return const LanguageDialogWidget();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(minHeight: height),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(getTranslated(context, 'Sign in'), style: kPrimaryStyle),
//                   20.kH,
//                   ReusedTextFormField(
//                     controller: _emailController,
//                     hintText: getTranslated(context, 'Email'),
//                     prefixIcon: Icons.email,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return getTranslated(
//                             context, 'Please enter your email');
//                       }
//                       return null;
//                     },
//                   ),
//                   20.kH,
//                   ReusedTextFormField(
//                     controller: _passwordController,
//                     hintText: getTranslated(context, 'Password'),
//                     prefixIcon: LineAwesome.user_lock_solid,
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return getTranslated(
//                             context, 'Please enter your password');
//                       }
//                       if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{8,}$')
//                           .hasMatch(value)) {
//                         return getTranslated(context, 'Password Description');
//                       }
//                       return null;
//                     },
//                   ),
//                   20.kH,
//                   ReusedPhoneNumberField(
//                     onPhoneNumberChanged: (phone) {
//                       setState(() {
//                         _phoneNumber = phone;
//                       });
//                     },
//                     validator: (phone) {
//                       if (phone == null || phone.number.isEmpty) {
//                         return getTranslated(
//                             context, 'Please enter a valid phone number');
//                       }
//                       return null;
//                     },
//                   ),
//                   20.kH,
//                   ReusedTextFormField(
//                     controller: _agentCodeController,
//                     hintText: getTranslated(context, 'Agent Code'),
//                     prefixIcon: Icons.person_outline,
//                     keyboardType: TextInputType.text,
//                   ),
//                   10.kH,
//                   CheckboxListTile(
//                     value: _acceptedTerms,
//                     onChanged: (value) {
//                       setState(() {
//                         _acceptedTerms = value!;
//                       });
//                     },
//                     title: RichText(
//                       text: TextSpan(
//                         text: getTranslated(context, 'I accept the '),
//                         style: Theme.of(context).textTheme.bodyLarge,
//                         children: <TextSpan>[
//                           TextSpan(
//                             text:
//                                 getTranslated(context, 'terms and conditions'),
//                             style:
//                                 Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                       color: Colors.blue,
//                                       decoration: TextDecoration.underline,
//                                     ),
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 _launchTermsUrl();
//                               },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   CustomButton(
//                     text: getTranslated(context, 'Sign in'),
//                     onPressed: () async {
//                       FocusScope.of(context).unfocus();
//
//                       if (_formKey.currentState!.validate()) {
//                         if (!_acceptedTerms) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(getTranslated(context,
//                                   'Please accept the terms and conditions')),
//                             ),
//                           );
//                           return;
//                         }
//
//                         try {
//                           await _authMethods.signUpWithEmailPhone(
//                             email: _emailController.text.trim(),
//                             password: _passwordController.text.trim(),
//                             phone: _phoneNumber!,
//                             acceptedTerms: _acceptedTerms,
//                             agentCode: _agentCodeController.text
//                                 .trim(), // Pass Agent Code
//                             context: context,
//                           );
//                           print('OTP sent for verification');
//                         } catch (e) {
//                           print('Sign-up failed: $e');
//                         }
//                       }
//                     },
//                   ),
//                   20.kH,
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: AutoSizeText(
//                           getTranslated(context, "Already have an account? "),
//                           style: Theme.of(context).textTheme.bodyLarge,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const LoginScreen()),
//                           );
//                         },
//                         child: Text(
//                           getTranslated(context, "Login"),
//                           style:
//                               Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/sign_in_screen.dart
