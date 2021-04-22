import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/photoview_screen.dart';
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
  List<dynamic> notifications;

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
    notifications ??= args[Constant.ARG_NOTIFICATIONS];

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Notifications'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            for (int i = 0; i < notifications.length; i++)
              GestureDetector(
                onTap: () => con.onTap(i),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.height * 0.12,
                      child: Image.network(
                        notifications[i][Constant.ARG_ONE_PHOTOMEMO].photoURL,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Flexible(
                        child: Text(
                            "  " + notifications[i][Constant.ARG_MESSAGE],
                            style: TextStyle(fontSize: 16))),
                  ],
                ),
              ),
          ]),
        ),
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

      bool unreadNotification = false;
      if (await FirebaseController.unreadNotificationExists(
          owner_uid: state.user.uid)) {
        unreadNotification = true;
      }

      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            Constant.ARG_USER: state.user,
            Constant.ARG_USER_INFO: state.userInfo,
            Constant.ARG_PHOTOMEMOLIST: photoMemoList,
            Constant.ARG_UNREAD_NOTIFICATION: unreadNotification,
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
          await FirebaseController.getPhotoMemoList(uid: state.user.uid);

      bool unreadNotification = false;
      if (await FirebaseController.unreadNotificationExists(
          owner_uid: state.user.uid)) {
        unreadNotification = true;
      }

      Navigator.pushNamed(state.context, UserHomeScreen.routeName, arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: photoMemoList,
        Constant.ARG_USER_INFO: state.userInfo,
        Constant.ARG_UNREAD_NOTIFICATION: unreadNotification,
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

  void onTap(int index) async {
    String onePhotoMemoUsername;
    String onePhotoMemoProfileURL;
    List<dynamic> onePhotoMemoComments;
    List<dynamic> onePhotoMemoLikes;
    bool onePhotoMemoLiked = false;
    try {
      onePhotoMemoLikes = await FirebaseController.getLikes(
          photoFilename: state
              .notifications[index][Constant.ARG_ONE_PHOTOMEMO].photoFilename);

      if (await FirebaseController.likeExists(
          photoFilename: state
              .notifications[index][Constant.ARG_ONE_PHOTOMEMO].photoFilename,
          email: state.user.email)) {
        onePhotoMemoLiked = true;
      }

      onePhotoMemoUsername = await FirebaseController.getUsername(
          email:
              state.notifications[index][Constant.ARG_ONE_PHOTOMEMO].createdBy);
      onePhotoMemoProfileURL = await FirebaseController.getProfilePicture(
          email:
              state.notifications[index][Constant.ARG_ONE_PHOTOMEMO].createdBy);
      onePhotoMemoComments = await FirebaseController.getComments(
          photoFilename: state
              .notifications[index][Constant.ARG_ONE_PHOTOMEMO].photoFilename);
    } catch (e) {
      print('============================$e');
    }
    await Navigator.pushNamed(state.context, PhotoViewScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_USER_INFO: state.userInfo,
          Constant.ARG_ONE_PHOTOMEMO: state.notifications[index]
              [Constant.ARG_ONE_PHOTOMEMO],
          Constant.ARG_ONE_PHOTOMEMO_USERNAME: onePhotoMemoUsername,
          Constant.ARG_ONE_PHOTOMEMO_PROFILE_PICTURE_URL:
              onePhotoMemoProfileURL,
          Constant.ARG_ONE_PHOTOMEMO_COMMENTS: onePhotoMemoComments,
          Constant.ARG_ONE_PHOTOMEMO_LIKES: onePhotoMemoLikes,
          Constant.ARG_ONE_PHOTOMEMO_LIKED: onePhotoMemoLiked,
        });
  }
}
