import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/myimage.dart';
import 'package:lesson3/screen/photoview_screen.dart';

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

    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    return Scaffold(
        appBar: AppBar(
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
              ));
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);

  void onTap(int index) async {
    String onePhotoMemoUsername;
    String onePhotoMemoProfileURL;
    List<dynamic> onePhotoMemoComments;
    try {
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
        });
  }
}
