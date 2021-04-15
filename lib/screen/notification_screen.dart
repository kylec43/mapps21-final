import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/sharedwith_screen.dart';
import 'package:lesson3/screen/userhome_screen.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/NotificationScreen';
  @override
  State<StatefulWidget> createState() {
    return _NotificationScreenState();
  }
}

class _NotificationScreenState extends State<NotificationScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User user;
  var userInfo;
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
    userInfo = args[Constant.ARG_USER_INFO];

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Notifications'),
        ),
        body: Text('Notification screen'),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Shared With Me',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_important),
              label: 'Notifications',
            ),
          ],
          currentIndex: 2,
          selectedItemColor: Colors.amber[800],
          onTap: con.onNavBarTapped,
        ),
      ),
    );
  }
}

class _Controller {
  _NotificationScreenState state;
  _Controller(this.state);

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            Constant.ARG_USER: state.user,
            Constant.ARG_USER_INFO: state.userInfo,
            Constant.ARG_PHOTOMEMOLIST: photoMemoList,
          });
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'get Shared PhotoMemo error',
        content: '$e',
      );
    }
  }

  void homeScreen() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoList(email: state.user.email);
      Navigator.pushNamed(state.context, UserHomeScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
        Constant.ARG_USER_INFO: state.userInfo,
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Firestore getPhotoMemoList error',
        content: '$e',
      );
    }
  }

  void onNavBarTapped(int index) {
    if (index == 0) {
      homeScreen();
    } else if (index == 1) {
      sharedWithMe();
    }
  }
}
