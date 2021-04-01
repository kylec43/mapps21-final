import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class ChangeEmailScreen extends StatefulWidget {
  static const routeName = '/changeEmailScreen';
  @override
  State<StatefulWidget> createState() {
    return _ChangeEmailState();
  }
}

class _ChangeEmailState extends State<ChangeEmailScreen> {
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
          title: Text('Change Email'),
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
                      hintText: 'New email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onSaved: con.saveEmail,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Confirm email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onSaved: con.saveConfirmEmail,
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
                      'Change email',
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
  _ChangeEmailState state;
  _Controller(this.state);
  String newEmail;
  String confirmEmail;
  String errorMessage;

  bool validEmail() {
    if (newEmail.contains('@') && newEmail.contains('.'))
      return true;
    else
      return false;
  }

  bool emailsMatch() {
    return newEmail == confirmEmail;
  }

  void changePassword() async {
    state.formKey.currentState.save();

    errorMessage = null;

    if (!validEmail()) {
      state.render(() => errorMessage = 'Invalid email');
      return;
    } else if (!emailsMatch()) {
      state.render(() => errorMessage = 'Emails do not match');
      return;
    }

    try {
      await FirebaseController.changeEmail(
          user: state.user, newEmail: newEmail);

      User user = FirebaseController.getCurrentUser();
      state.render(() => state.args[Constant.ARG_USER] = user);

      MyDialog.info(
        context: state.context,
        title: 'Success',
        content: 'Your email has been changed successfully',
        onPressed: () {
          Navigator.of(state.context).pop();
        },
      );
    } catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          state.render(() => errorMessage = 'Email is already in use');
          break;
        default:
          state.render(() => errorMessage = '$e');
          break;
      }
    }
  }

  void saveEmail(String value) {
    newEmail = value;
  }

  void saveConfirmEmail(String value) {
    confirmEmail = value;
  }

  Future<bool> goBack() async {
    Navigator.pop(state.context, state.args);
    return true;
  }
}
