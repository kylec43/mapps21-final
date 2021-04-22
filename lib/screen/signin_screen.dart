import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/forgotpassword_screen.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/signup_screen.dart';
import 'package:lesson3/screen/userhome_screen.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/waterfall.gif"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Sign In'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Container(
            color: Colors.black54,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 15.0, bottom: 20.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'PhotoMemo',
                            style: TextStyle(
                                fontFamily: 'Pacifico',
                                fontSize: 40.0,
                                color: Colors.white),
                          ),
                        ),
                        Text(
                          'Sign in, please!',
                          style: TextStyle(
                              fontFamily: 'Pacifico', color: Colors.white),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            fillColor: Colors.white70,
                            filled: true,
                            errorStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: con.validateEmail,
                          onSaved: con.saveEmail,
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            fillColor: Colors.white70,
                            filled: true,
                            errorStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          obscureText: true,
                          autocorrect: false,
                          validator: con.validatePassword,
                          onSaved: con.savePassword,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        RaisedButton(
                          onPressed: con.signIn,
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        Divider(
                          color: Colors.blue[300],
                          thickness: 1,
                        ),
                        RaisedButton(
                          onPressed: con.signUp,
                          child: Text(
                            'Create a new account',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ForgotPasswordScreen.routeName,
                            );
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState state;
  _Controller(this.state);
  String email;
  String password;

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.'))
      return null;
    else
      return '• Invalid email address';
  }

  void saveEmail(String value) {
    email = value;
  }

  String validatePassword(String value) {
    if (value.length < 6)
      return '• Password is too short (min. 6 characters)';
    else
      return null;
  }

  void savePassword(String value) {
    password = value;
  }

  void signIn() async {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    User user;
    var userInfo;
    MyDialog.circularProgressStart(state.context);
    try {
      user = await FirebaseController.signIn(email: email, password: password);
      userInfo = await FirebaseController.getUserAccountInfo(user: user);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Sign In Error',
        content: e.toString(),
      );
      return;
    }

    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoList(uid: user.uid);
      MyDialog.circularProgressStop(state.context);

      bool unreadNotification = false;
      if (await FirebaseController.unreadNotificationExists(
          owner_uid: user.uid)) {
        unreadNotification = true;
      }
      print(unreadNotification);
      Navigator.pushNamed(state.context, UserHomeScreen.routeName, arguments: {
        Constant.ARG_USER: user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
        Constant.ARG_USER_INFO: userInfo,
        Constant.ARG_UNREAD_NOTIFICATION: unreadNotification,
      });
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Firestore getPhotoMemoList error',
        content: '$e',
      );
    }
  }

  void signUp() {
    //navigate to sign up screen
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }
}
