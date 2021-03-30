import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class ChangeUsernameScreen extends StatefulWidget {
  static const routeName = '/changeUsernameScreen';
  @override
  State<StatefulWidget> createState() {
    return _ChangeUsernameState();
  }
}

class _ChangeUsernameState extends State<ChangeUsernameScreen> {
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
          title: Text('Change Username'),
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
                  Text(
                    'Current Username: ${user.displayName}',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'New username',
                    ),
                    autocorrect: false,
                    onSaved: con.saveUsername,
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
                    onPressed: con.changeUsername,
                    child: Text(
                      'Change username',
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
  _ChangeUsernameState state;
  _Controller(this.state);
  String newUsername;
  String errorMessage;

  bool validUsername() {
    if (newUsername.length < 6) {
      return false;
    } else {
      return true;
    }
  }

  void changeUsername() async {
    state.formKey.currentState.save();

    errorMessage = null;

    if (!validUsername()) {
      state.render(() => errorMessage = 'Invalid username (min. 6 characters)');
      return;
    }

    try {
      await FirebaseController.changeUsername(newUsername);

      User user = FirebaseController.getCurrentUser();
      state.render(() => state.args[Constant.ARG_USER] = user);

      MyDialog.info(
        context: state.context,
        title: 'Success',
        content: 'Your username has been changed successfully',
        onPressed: () {
          Navigator.of(state.context).pop();
        },
      );
    } catch (e) {
      if (e.message == Constant.USERNAME_NOT_UNIQUE_ERROR) {
        state.render(() => errorMessage = 'Username is already taken');
      } else {
        state.render(() => errorMessage = '$e');
      }
    }
  }

  void saveUsername(String value) {
    newUsername = value;
  }

  Future<bool> goBack() async {
    Navigator.pop(state.context, state.args);
    return true;
  }
}
