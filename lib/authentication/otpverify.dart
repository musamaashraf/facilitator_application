import 'package:facilitatorpro/database/databasemethods.dart';
import 'package:facilitatorpro/routes/routenames.dart';
import 'package:facilitatorpro/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({Key? key}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberEditingController = TextEditingController();
  int? resendToken = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String error = '';
  bool codeSent = false;
  String currentVID = '', currentSMSCode = '';
  final User? currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController pinCodeEditingController = TextEditingController();
  final DatabaseMethods databaseMethods = DatabaseMethods();

  void completeVerification() async {
    final PhoneAuthCredential _authCredential =
        await PhoneAuthProvider.credential(
            verificationId: currentVID, smsCode: currentSMSCode);
    final UserCredential user =
        await currentUser!.linkWithCredential(_authCredential);

    if (user != null) {
      if (user.user!.uid == currentUser!.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Phone Number Verified!',
              style: TextStyle(
                color: Palette.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        databaseMethods
            .addUser({'verified': true}, currentUser!.uid).then((value) {
          Navigator.pushNamed(context, profileRoute);
        });
      }
    } else {
      setState(() {
        error = 'Some error occured. Please Try Again!';
      });
    }
  }

  void verifyPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumberEditingController.text.trim(),
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('Verification Completed!!\n\n');

        final UserCredential user =
            await currentUser!.linkWithCredential(credential);

        if (user != null) {
          if (user.user!.uid == currentUser!.uid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Phone Number Verified!',
                  style: TextStyle(
                    color: Palette.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
            databaseMethods
                .addUser({'verified': true}, currentUser!.uid).then((value) {
              Navigator.pushNamed(context, profileRoute);
            });
          }
        } else {
          setState(() {
            error = 'Some error occured. Please Try Again!';
          });
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification Failed!\n\n');
        if (e.code == 'invalid-phone-number') {
          setState(() {
            error = 'The provided phone number is not valid.';
          });
          print('The provided phone number is not valid.');
        }
        if (e.message!.contains('Problem retrieving SafetyNet')) {
          setState(() {
            error = 'Something went wrong please try again later!';
          });
        }
        if (e.message!.contains('SMS verification code request failed:')) {
          setState(() {
            error = 'Something went wrong please try again later!';
          });
        } else {
          print('\n\nError Occured: ${e.message}\n\n');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Code Sent\n\n');
        currentVID = verificationId;
        this.resendToken = resendToken;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Code Sent!',
              style: TextStyle(
                color: Palette.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        setState(() {
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.mobile,
                    size: MediaQuery.of(context).size.height * 0.2,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  const Text(
                    'OTP Verification',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Palette.formHeading,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  const Text(
                    'we will send you a one-time password to this mobile number.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.formHeading,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  const Text(
                    'Enter Mobile Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.formLabel,
                      fontSize: 18,
                    ),
                  ),
                  codeSent
                      ? PinCodeTextField(
                          appContext: context,
                          length: 6,
                          onChanged: (value) {
                            currentSMSCode = value;
                          },
                          controller: pinCodeEditingController,
                          pinTheme: PinTheme(
                            activeColor: Palette.primary,
                            inactiveColor: Palette.formLabel,
                          ),
                        )
                      : TextFormField(
                          controller: phoneNumberEditingController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Palette.formLabel,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.formBorder,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a phone number!';
                            }
                          },
                        ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  (error == '')
                      ? Container()
                      : Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        codeSent ? completeVerification() : verifyPhone();
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
                          child: Text(
                            codeSent ? 'Verify OTP' : 'Get OTP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Palette.white,
                              fontSize: 15,
                            ),
                          )),
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
