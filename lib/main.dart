import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/accountsettings_screen.dart';
import 'package:lesson3/screen/addphotomemo_screen.dart';
import 'package:lesson3/screen/changeemail_screen.dart';
import 'package:lesson3/screen/changepassword_screen.dart';
import 'package:lesson3/screen/changeprofilepicture_screen.dart';
import 'package:lesson3/screen/changeusername_screen.dart';
import 'package:lesson3/screen/detailedview_screen.dart';
import 'package:lesson3/screen/forgotpassword_screen.dart';
import 'package:lesson3/screen/sharedwith_screen.dart';
import 'package:lesson3/screen/signin_screen.dart';
import 'package:lesson3/screen/signup_screen.dart';
import 'package:lesson3/screen/userhome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: Constant.DEV,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.green,
        ),
        initialRoute: SignInScreen.routeName,
        routes: {
          SignInScreen.routeName: (context) => SignInScreen(),
          UserHomeScreen.routeName: (context) => UserHomeScreen(),
          AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
          DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
          SignUpScreen.routeName: (context) => SignUpScreen(),
          SharedWithScreen.routeName: (context) => SharedWithScreen(),
          ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
          AccountSettingsScreen.routeName: (context) => AccountSettingsScreen(),
          ChangeUsernameScreen.routeName: (context) => ChangeUsernameScreen(),
          ChangePasswordScreen.routeName: (context) => ChangePasswordScreen(),
          ChangeProfilePictureScreen.routeName: (context) =>
              ChangeProfilePictureScreen(),
          ChangeEmailScreen.routeName: (context) => ChangeEmailScreen(),
        });
  }
}
