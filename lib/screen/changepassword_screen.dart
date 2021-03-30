import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/changePasswordScreen';
  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User user;
  Map args;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    args ??= ModalRoute.of(context).settings.arguments;
    user = args[Constant.ARG_USER];

    return WillPopScope(
      onWillPop: con.goBack,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'New password',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    onSaved: con.savePassword,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    onSaved: con.saveConfirmPassword,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  con.errorMessage == null
                      ? SizedBox(
                          height: 1.0,
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '• ' + con.errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                          ),
                        ),
                  SizedBox(
                    height: 15.0,
                  ),
                  RaisedButton(
                    onPressed: con.changePassword,
                    child: Text(
                      'Change password',
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
  _ChangePasswordState state;
  _Controller(this.state);
  String newPassword;
  String confirmPassword;
  String errorMessage;

  bool validPassword() {
    if (newPassword.length < 6) {
      return false;
    } else {
      return true;
    }
  }

  bool passwordsMatch() {
    return newPassword == confirmPassword;
  }

  void changePassword() async {
    state.formKey.currentState.save();

    errorMessage = null;

    if (!validPassword()) {
      state.render(() => errorMessage = 'Invalid password (min. 6 characters)');
      return;
    } else if (!passwordsMatch()) {
      state.render(() => errorMessage = 'Passwords do not match');
      return;
    }

    try {
      await FirebaseController.changePassword(
          user: state.user, newPassword: newPassword);

      User user = FirebaseController.getCurrentUser();
      state.render(() => state.args[Constant.ARG_USER] = user);

      MyDialog.info(
        context: state.context,
        title: 'Success',
        content: 'Your password has been changed successfully',
        onPressed: () {
          Navigator.of(state.context).pop();
        },
      );
    } catch (e) {
      state.render(() => errorMessage = '$e');
    }
  }

  void savePassword(String value) {
    newPassword = value;
  }

  void saveConfirmPassword(String value) {
    confirmPassword = value;
  }

  Future<bool> goBack() async {
    Navigator.pop(state.context, state.args);
    return true;
  }
}
