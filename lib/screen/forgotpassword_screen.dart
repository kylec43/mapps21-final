import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/model/constant.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                SizedBox(
                  height: 15.0,
                ),
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
  String undefinedErrorMessage;

  void sendResetEmail() {
    try {
      FirebaseController.sendResetEmail(email);

      MyDialog.info(
          context: state.context,
          title: 'Email Sent',
          content: 'A reset password link has been sent to your email.',
          onPressed: () {
            Navigator.of(state.context).pop();
            Navigator.of(state.context).pop();
          });
    } catch (e) {
      state.render(() => undefinedErrorMessage = '$e');
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
