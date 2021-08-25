import 'dart:io';

import 'package:facilitatorpro/database/databasemethods.dart';
import 'package:facilitatorpro/routes/routenames.dart';
import 'package:facilitatorpro/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController dateofbirth = TextEditingController();

  String? gender;
  List<String> genderList = ['Male', 'Female', 'Other'];

  File _image = File('');
  final picker = ImagePicker();
  String? status = 'null', error, validError;
  String link = '';
  bool uploadingImage = false;
  DatabaseMethods databaseMethods = DatabaseMethods();
  User? user = FirebaseAuth.instance.currentUser;

  Future<String> uploadImageToFirebase() async {
    String fileName = basename(_image.path);
    Reference reference =
        FirebaseStorage.instance.ref().child('users/$fileName');
    await reference.putFile(_image).then((p0) {
      if (p0.ref.getDownloadURL() != null) {
        setState(() {
          uploadingImage = false;
        });
      }
    });
    return await reference.getDownloadURL();
  }

  Future getImage(bool gallery) async {
    await picker
        .pickImage(source: gallery ? ImageSource.gallery : ImageSource.camera)
        .then((value) {
      if (value != null) {
        _image = File(value.path);
        setState(() {
          status = 'image';
        });
        print('Image selected');
      } else {
        print('No image selected.');
      }
      return value;
    });
  }

  Future<bool?> uploadImage() async {
    print('in  here!');
    if (_image.path.isNotEmpty) {
      setState(() {
        uploadingImage = true;
      });
      await uploadImageToFirebase().then((value) {
        if (value != null) {
          link = value;
          print('image uploaded');
          return true;
        } else {
          print('Error uploading image');
          return false;
        }
      });
    }
  }

  void showAlertDialogue(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Choose image source',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                  onPressed: () {
                    getImage(true);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: const Text('Gallery')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    getImage(false);
                  },
                  child: const Text('Camera')),
            ],
          );
        });
  }

  void completeProfile(BuildContext context) async {
    if (_formKey.currentState!.validate() &&
        gender != null &&
        _image.path.isNotEmpty) {
      await uploadImage().then((value) {
        print(value);
        if (link != '') {
          Map<String, dynamic> userData = {
            'user-name': username.text.trim().toLowerCase(),
            'first-name': firstname.text,
            'last-name': lastname.text,
            'date-of-birth': dateofbirth.text.trim(),
            'gender': gender,
            'profile-image': link,
          };
          databaseMethods.addUser(userData, user!.uid).then((value) {
            Navigator.pushNamed(context, profileRoute);
          });
        }
      });
    }
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
                  GestureDetector(
                    onTap: () {
                      showAlertDialogue(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0.0, 8.0),
                              color: Palette.formLabel.withOpacity(0.4),
                              blurRadius: 20.0),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: MediaQuery.of(context).size.width * 0.30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: (status == 'null')
                            ? FaIcon(FontAwesomeIcons.camera,
                                size: MediaQuery.of(context).size.width * 0.24)
                            : Image.file(
                                _image,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.30,
                                height:
                                    MediaQuery.of(context).size.width * 0.30,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Your username',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a username!';
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: firstname,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Your first name',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name!';
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: lastname,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Your last name',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name!';
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: dateofbirth,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: '( dd-mm-yy )',
                      labelStyle: TextStyle(
                        color: Palette.formLabel,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Palette.formBorder,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your date of birth!';
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  DropdownButton(
                    items: genderList.map((gen) {
                      return DropdownMenuItem(
                          child: Text(
                            gen,
                          ),
                          value: gen);
                    }).toList(),
                    value: gender,
                    hint: const Text('Select a gender'),
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        completeProfile(context);
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
                            'Complete',
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
            )),
      )),
    );
  }
}
