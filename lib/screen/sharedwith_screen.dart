import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/notification_screen.dart';
import 'package:lesson3/screen/photoview_screen.dart';
import 'package:lesson3/screen/userhome_screen.dart';

import 'myview/mydialog.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  _Controller con;
  User user;
  var userInfo;
  List<PhotoMemo> photoMemoList;
  var unreadNotification;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    userInfo ??= args[Constant.ARG_USER_INFO];
    unreadNotification ??= args[Constant.ARG_UNREAD_NOTIFICATION];

    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Shared With Me'),
        ),
        body: photoMemoList.length == 0
            ? Text(
                'No PhotoMemos shared with me',
                style: Theme.of(context).textTheme.headline5,
              )
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => con.onTap(index),
                  child: Card(
                    elevation: 7.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.33,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: MyImage.network(
                              url: photoMemoList[index].photoURL,
                              context: context,
                            ),
                          ),
                        ),
                        Text(
                          'Title: ${photoMemoList[index].title}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text('Memo: ${photoMemoList[index].memo}'),
                        Text('Created By: ${photoMemoList[index].createdBy}'),
                        Text('Updated At: ${photoMemoList[index].timestamp}'),
                        Text('SharedWith: ${photoMemoList[index].sharedWith}'),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Shared With Me',
            ),
            unreadNotification == true
                ? BottomNavigationBarItem(
                    icon: GlowIcon(Icons.notification_important,
                        size: 40,
                        color: Colors.green[500],
                        glowColor: Colors.green[200]),
                    label: 'Notifications',
                  )
                : BottomNavigationBarItem(
                    icon: Icon(Icons.notification_important),
                    label: 'Notifications',
                  ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.amber[800],
          onTap: con.onNavBarTapped,
        ),
      ),
    );
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);

  void onTap(int index) async {
    String onePhotoMemoUsername;
    String onePhotoMemoProfileURL;
    List<dynamic> onePhotoMemoComments;
    List<dynamic> onePhotoMemoLikes;
    bool onePhotoMemoLiked = false;
    try {
      onePhotoMemoLikes = await FirebaseController.getLikes(
          photoFilename: state.photoMemoList[index].photoFilename);

      if (await FirebaseController.likeExists(
          photoFilename: state.photoMemoList[index].photoFilename,
          email: state.user.email)) {
        onePhotoMemoLiked = true;
      }

      onePhotoMemoUsername = await FirebaseController.getUsername(
          email: state.photoMemoList[index].createdBy);
      onePhotoMemoProfileURL = await FirebaseController.getProfilePicture(
          email: state.photoMemoList[index].createdBy);
      onePhotoMemoComments = await FirebaseController.getComments(
          photoFilename: state.photoMemoList[index].photoFilename);
    } catch (e) {
      print('============================$e');
    }
    await Navigator.pushNamed(state.context, PhotoViewScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_USER_INFO: state.userInfo,
          Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
          Constant.ARG_ONE_PHOTOMEMO_USERNAME: onePhotoMemoUsername,
          Constant.ARG_ONE_PHOTOMEMO_PROFILE_PICTURE_URL:
              onePhotoMemoProfileURL,
          Constant.ARG_ONE_PHOTOMEMO_COMMENTS: onePhotoMemoComments,
          Constant.ARG_ONE_PHOTOMEMO_LIKES: onePhotoMemoLikes,
          Constant.ARG_ONE_PHOTOMEMO_LIKED: onePhotoMemoLiked,
        });

    var unreadNotification = await FirebaseController.unreadNotificationExists(
        owner: state.user.email);
    state.render(() async => state.unreadNotification = unreadNotification);
  }

  void homeScreen() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoList(email: state.user.email);

      bool unreadNotification = false;
      if (await FirebaseController.unreadNotificationExists(
          owner: state.user.email)) {
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

  void notification() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );

      List<Map<String, dynamic>> notifications =
          await FirebaseController.getNotifications(owner: state.user.email);
      await Navigator.pushNamed(state.context, NotificationScreen.routeName,
          arguments: {
            Constant.ARG_USER: state.user,
            Constant.ARG_USER_INFO: state.userInfo,
            Constant.ARG_PHOTOMEMOLIST: photoMemoList,
            Constant.ARG_NOTIFICATIONS: notifications,
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

  void onNavBarTapped(int index) {
    if (index == 0) {
      homeScreen();
    } else if (index == 2) {
      notification();
    } else {}
  }
}
