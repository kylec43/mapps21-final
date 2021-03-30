import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/changeemail_screen.dart';
import 'package:lesson3/screen/changepassword_screen.dart';
import 'package:lesson3/screen/changeprofilepicture_screen.dart';
import 'package:lesson3/screen/changeusername_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  static const routeName = '/accountSettingsScreen';
  @override
  State<StatefulWidget> createState() {
    return _AccountSettingsState();
  }
}

class _AccountSettingsState extends State<AccountSettingsScreen> {
  _Controller con;
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
          title: Text('Account Settings'),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text('Change email'),
                  onPressed: con.changeEmail,
                ),
                SizedBox(height: 15),
                RaisedButton(
                  child: Text('Change username'),
                  onPressed: con.changeUsername,
                ),
                SizedBox(height: 15),
                RaisedButton(
                  child: Text('Change password'),
                  onPressed: con.changePassword,
                ),
                SizedBox(height: 15),
                RaisedButton(
                  child: Text('Change profile picture'),
                  onPressed: con.changeProfilePicture,
                ),
              ]),
        ),
      ),
    );
  }
}

class _Controller {
  _AccountSettingsState state;
  _Controller(this.state);

  void changeUsername() async {
    final result = await Navigator.pushNamed(
        state.context, ChangeUsernameScreen.routeName,
        arguments: state.args);

    state.render(() => state.args = result);
  }

  void changePassword() async {
    final result = await Navigator.pushNamed(
        state.context, ChangePasswordScreen.routeName,
        arguments: state.args);

    state.render(() => state.args = result);
  }

  void changeEmail() async {
    final result = await Navigator.pushNamed(
        state.context, ChangeEmailScreen.routeName,
        arguments: state.args);

    state.render(() => state.args = result);
  }

  void changeProfilePicture() async {
    final result = await Navigator.pushNamed(
        state.context, ChangeProfilePictureScreen.routeName,
        arguments: state.args);

    state.render(() => state.args = result);
  }

  Future<bool> goBack() async {
    Navigator.pop(state.context, state.args);
    return true;
  }
}
