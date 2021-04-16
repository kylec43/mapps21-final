import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/accountsettings_screen.dart';
import 'package:lesson3/screen/addphotomemo_screen.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/notification_screen.dart';
import 'package:lesson3/screen/photoview_screen.dart';
import 'package:lesson3/screen/sharedwith_screen.dart';
import 'package:lesson3/screen/signin_screen.dart';
import 'package:flutter_glow/flutter_glow.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;
  var userInfo;
  List<PhotoMemo> photoMemoList;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map args;
  var unreadNotification;

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
    unreadNotification ??= args[Constant.ARG_UNREAD_NOTIFICATION];

    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return WillPopScope(
      onWillPop: () =>
          Future.value(false), // Android System Back button disabled
      child: Scaffold(
        appBar: AppBar(
          // title: Text('User Home'),
          actions: [
            con.delIndex != null
                ? IconButton(
                    icon: Icon(Icons.cancel), onPressed: con.cancelDelete)
                : Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKeyString,
                        ),
                      ),
                    )),
            con.delIndex != null
                ? IconButton(icon: Icon(Icons.delete), onPressed: con.delete)
                : IconButton(
                    icon: Icon(Icons.search),
                    onPressed: con.search,
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userInfo[Constant.ARG_PROFILE_PICTURE_URL],
                  ),
                ),
                accountName: Text(
                  userInfo[Constant.ARG_USERNAME],
                ),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Account Settings'),
                onTap: con.accountSettings,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: photoMemoList.length == 0
            ? Text(
                'No PhotoMemos Found!',
                style: Theme.of(context).textTheme.headline5,
              )
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  color: con.delIndex != null && con.delIndex == index
                      ? Theme.of(context).highlightColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    leading: MyImage.network(
                      url: photoMemoList[index].photoURL,
                      context: context,
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(photoMemoList[index].memo.length >= 20
                            ? photoMemoList[index].memo.substring(0, 20) + '...'
                            : photoMemoList[index].memo),
                        Text('Created By: ${photoMemoList[index].createdBy}'),
                        Text('Shared With: ${photoMemoList[index].sharedWith}'),
                        Text('Updated At: ${photoMemoList[index].timestamp}'),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
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
          currentIndex: 0,
          selectedItemColor: Colors.amber[800],
          onTap: con.onNavBarTapped,
        ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);
  int delIndex;
  String keyString;

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_USER_INFO: state.userInfo,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList
      },
    );

    state.render(() {}); // rerender the screen
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      //do nothing
    }
    Navigator.of(state.context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (Route<dynamic> route) => false);
  }

  void onTap(int index) async {
    if (delIndex != null) return;

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

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );

      bool unreadNotification = false;
      if (await FirebaseController.unreadNotificationExists(
          owner: state.user.email)) {
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

  void onLongPress(int index) {
    if (delIndex != null) return;
    state.render(() => delIndex = index);
  }

  void cancelDelete() {
    state.render(() => delIndex = null);
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[delIndex];
      await FirebaseController.deletePhotoMemo(p);
      state.render(() {
        state.photoMemoList.removeAt(delIndex);
        delIndex = null;
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete PhotoMemo error',
        content: '$e',
      );
    }
  }

  void saveSearchKeyString(String value) {
    keyString = value;
  }

  void search() async {
    state.formKey.currentState.save();
    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];
    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }

    try {
      List<PhotoMemo> results;
      if (searchKeys.isNotEmpty) {
        results = await FirebaseController.searchImage(
          createdBy: state.user.email,
          searchLabels: searchKeys,
        );
      } else {
        results =
            await FirebaseController.getPhotoMemoList(email: state.user.email);
      }
      state.render(() => state.photoMemoList = results);
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Search error', content: '$e');
    }
  }

  void accountSettings() async {
    await Navigator.pushNamed(state.context, AccountSettingsScreen.routeName,
        arguments: state.args);

    try {
      List<PhotoMemo> results =
          await FirebaseController.getPhotoMemoList(email: state.user.email);

      var unreadNotification =
          await FirebaseController.unreadNotificationExists(
              owner: state.user.email);
      state.render(() {
        state.photoMemoList = results;
        state.unreadNotification = unreadNotification;
      });
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Search error', content: '$e');
    }
  }

  void onNavBarTapped(int index) {
    if (index == 1) {
      sharedWithMe();
    } else if (index == 2) {
      notification();
    }
  }
}
