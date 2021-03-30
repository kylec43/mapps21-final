import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/model/constant.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File photo;
  String progressMessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Profile Picture',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: photo == null
                          ? ClipOval(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "images/default_profile_picture.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                photo,
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () => con.getPhoto(Constant.SRC_CAMERA),
                        child: Row(
                          children: [
                            Icon(Icons.photo_camera),
                            Text("Camera"),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.0),
                      RaisedButton(
                        onPressed: () => con.getPhoto(Constant.SRC_GALLERY),
                        child: Row(
                          children: [
                            Icon(Icons.photo_library),
                            Text("Gallery"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 45.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onSaved: con.saveEmail,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email Confirmation',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onSaved: con.saveEmailConfirm,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Username (min. 6 characters)',
                    ),
                    autocorrect: false,
                    onSaved: con.saveUsername,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password (min. 6 characters)',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    onSaved: con.savePassword,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password Confirmation (min. 6 characters)',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    onSaved: con.savePasswordConfirm,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  con.undefinedErrorMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ' + con.undefinedErrorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                        ),
                  con.emailErrorMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ' + con.emailErrorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                        ),
                  con.usernameErrorMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ' + con.usernameErrorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                        ),
                  con.passwordErrorMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ' + con.passwordErrorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                        ),
                  SizedBox(height: 20),
                  progressMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Text(
                          progressMessage,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                  RaisedButton(
                    onPressed: con.createAccount,
                    child: Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.button,
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

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String email;
  String password;
  String passwordConfirm;
  String passwordErrorMessage;
  String emailConfirm;
  String emailErrorMessage;
  String emailInUserErrorMessage;
  String username;
  String usernameErrorMessage;
  String undefinedErrorMessage;

  void createAccount() async {
    if (!state.formKey.currentState.validate()) return;
    state.render(() => passwordErrorMessage = null);
    state.formKey.currentState.save();

    //validate if valid username, password, and email format
    bool errorExists = false;

    if (!validUsername()) {
      state.render(() =>
          usernameErrorMessage = 'Username is too short (min. 6 characters)');
      errorExists = true;
    } else {
      state.render(() => usernameErrorMessage = null);
    }

    if (!validEmail()) {
      state.render(() => emailErrorMessage = 'Invalid Email');
      errorExists = true;
    } else if (email != emailConfirm) {
      state.render(() => emailErrorMessage = 'Emails do not match');
      errorExists = true;
    } else {
      state.render(() => emailErrorMessage = null);
    }

    if (!validPassword()) {
      state.render(() =>
          passwordErrorMessage = 'Password is too short (min. 6 characters)');
      errorExists = true;
    } else if (password != passwordConfirm) {
      state.render(() => passwordErrorMessage = 'Passwords do not match');
      errorExists = true;
    } else {
      state.render(() => passwordErrorMessage = null);
    }

    if (errorExists) return;

    MyDialog.circularProgressStart(state.context);

    try {
      await FirebaseController.createAccount(
        email: email,
        password: password,
        username: username,
        profilePicture: state.photo != null ? state.photo : null,
        listener: (double progress) {
          state.render(() {
            if (progress == null)
              state.progressMessage = null;
            else {
              progress *= 100;
              state.progressMessage =
                  'Creating Account: ' + progress.toStringAsFixed(1) + ' %';
            }
          });
        },
      );

      state.render(() => undefinedErrorMessage = null);

      MyDialog.circularProgressStop(state.context);

      MyDialog.info(
        context: state.context,
        title: 'Account Created!',
        content: 'Go to Sign In to use the app',
        onPressed: () {
          Navigator.of(state.context).pop();
          Navigator.of(state.context).pop();
        },
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);

      switch (e.message) {
        case Constant.USERNAME_NOT_UNIQUE_ERROR:
          state
              .render(() => usernameErrorMessage = 'Username is already taken');
          break;
      }

      switch (e.code) {
        case 'email-already-in-use':
          state.render(() => emailErrorMessage = 'Email is already in use');
          break;
        default:
          state.render(() => undefinedErrorMessage = '$e');
          break;
      }
    }
  }

  bool validEmail() {
    if (email.contains('@') && email.contains('.'))
      return true;
    else
      return false;
  }

  void saveEmail(String value) {
    email = value;
  }

  bool validPassword() {
    if (password.length < 6)
      return false;
    else
      return true;
  }

  bool validUsername() {
    if (username.length < 6)
      return false;
    else
      return true;
  }

  void savePassword(String value) {
    password = value;
  }

  void savePasswordConfirm(String value) {
    passwordConfirm = value;
  }

  void saveEmailConfirm(String value) {
    emailConfirm = value;
  }

  void saveUsername(String value) {
    username = value;
  }

  void getPhoto(String src) async {
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }

      if (_imageFile == null) return; //selection canceled
      state.render(() => state.photo = File(_imageFile.path));
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: 'Failed to get picture',
          content: '$e');
    }
  }
}
