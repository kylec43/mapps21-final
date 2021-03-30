import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgotPasswordScreen';
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
        title: Text('Forgot Password?'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 24.0, left: 24),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Enter your email',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onSaved: con.saveEmail,
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
                  onPressed: con.sendResetEmail,
                  child: Text(
                    'Send Recovery Link',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ForgotPasswordState state;
  _Controller(this.state);
  String email;
  String errorMessage;

  void sendResetEmail() {
    state.formKey.currentState.save();

    if (!validEmail()) {
      state.render(() => errorMessage = 'Email is invalid');
      return;
    }

    try {
      FirebaseController.sendResetEmail(email);

      MyDialog.info(
          context: state.context,
          title: 'Email Sent',
          content:
              'A reset password link has been sent to your email if it is registered.',
          onPressed: () {
            Navigator.of(state.context).pop();
            Navigator.of(state.context).pop();
          });
    } catch (e) {
      state.render(() => errorMessage = '$e');
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
}
