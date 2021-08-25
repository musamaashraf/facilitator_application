import 'package:facilitatorpro/database/databasemethods.dart';
import 'package:facilitatorpro/routes/routenames.dart';
import 'package:facilitatorpro/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();

  final _formKey = GlobalKey<FormState>();

  void validate() async {
    if (_formKey.currentState!.validate()) {
      await databaseMethods
          .signUpWithEmailAndPassword(
              email: emailEditingController.text.trim(),
              password: passwordEditingController.text.trim())
          .then((value) async {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        print(uid);
        if (uid != null) {
          Navigator.pushNamed(context, otpVerificationRoute);
        }
      }).catchError((error) {
        print('Error Occured: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            padding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  const Text(
                    'Sign up',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Palette.formHeading,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    controller: emailEditingController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an email!';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email address!';
                      }
                    },
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: passwordEditingController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a passowrd!';
                      }
                      if (value.length < 6) {
                        return 'Password should be of 6 or more characters!';
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        validate();
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 22.0),
                          width: MediaQuery.of(context).size.width * 0.50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Palette.primary,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Text(
                            'Sign up',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Palette.white,
                              fontSize: 15,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, signInRoute);
                      },
                      child: const Text(
                        'Already have an account? Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Palette.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
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
