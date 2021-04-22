import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/detailedview_screen.dart';
import 'package:lesson3/screen/myview/myimage.dart';

import 'myview/mydialog.dart';

class PhotoViewScreen extends StatefulWidget {
  static const routeName = '/photoViewScreen';
  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoViewScreen> {
  _Controller con;
  User user;
  var userInfo;
  PhotoMemo onePhotoMemo;
  String onePhotoMemoUsername;
  String onePhotoMemoProfilePictureURL;
  Map args;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<dynamic> comments;
  List<dynamic> likes;
  bool liked;
  var commentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    args ??= ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    userInfo ??= args[Constant.ARG_USER_INFO];

    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoUsername ??= args[Constant.ARG_ONE_PHOTOMEMO_USERNAME];
    onePhotoMemoProfilePictureURL ??=
        args[Constant.ARG_ONE_PHOTOMEMO_PROFILE_PICTURE_URL];
    comments ??= args[Constant.ARG_ONE_PHOTOMEMO_COMMENTS];
    likes ??= args[Constant.ARG_ONE_PHOTOMEMO_LIKES];
    liked ??= args[Constant.ARG_ONE_PHOTOMEMO_LIKED];

    return Scaffold(
      appBar: AppBar(
        title: Text('Photo View'),
        actions: [
          user.email == onePhotoMemo.createdBy
              ? FlatButton(
                  textColor: Colors.white,
                  onPressed: con.goToDetailedView,
                  child: Row(
                    children: [
                      Text("Detailed View", style: TextStyle(fontSize: 16)),
                      Icon(Icons.edit),
                    ],
                  ),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                )
              : Text(''),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 7.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.16,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: ClipOval(
                          child: Image.network(
                            onePhotoMemoProfilePictureURL,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Text('  $onePhotoMemoUsername',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text('Updated At: ${onePhotoMemo.timestamp}',
                        style: TextStyle(fontSize: 13)),
                  ),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: MyImage.network(
                      url: onePhotoMemo.photoURL,
                      context: context,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          child: IconButton(
                              iconSize: 30,
                              icon: liked
                                  ? const Icon(
                                      Icons.thumb_up_alt_rounded,
                                      color: Colors.blue,
                                    )
                                  : const Icon(Icons.thumb_up_alt_outlined),
                              onPressed: con.likeHandler),
                        ),
                        SizedBox(width: 5),
                        likes.length == 1
                            ? Text('1 person likes this')
                            : Text(
                                likes.length.toString() + " people like this"),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${onePhotoMemo.title}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.black),
                  Text(
                    '${onePhotoMemo.memo}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(color: Colors.black),
                ],
              ),
            ),
            SizedBox(height: 50),
            Form(
              key: formKey,
              child: Card(
                elevation: 7.0,
                child: Column(
                  children: [
                    Divider(color: Colors.black),
                    Text('Post a comment',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.black),
                    TextFormField(
                      controller: commentInputController,
                      decoration: InputDecoration(
                        hintText: 'Enter comment...',
                      ),
                      autocorrect: true,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      validator: con.validateComment,
                      onSaved: con.saveComment,
                    ),
                    RaisedButton(
                      child: Text('Post comment',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: con.submitComment,
                    ),
                    Divider(color: Colors.black),
                  ],
                ),
              ),
            ),
            SizedBox(height: 35),
            Card(
              elevation: 7.0,
              child: Column(
                children: [
                  Divider(color: Colors.black),
                  Text('View comments',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.black),
                  for (int i = 0; i < comments.length; i++)
                    Column(children: [
                      (user.email == onePhotoMemo.createdBy ||
                              user.email == comments[i][Constant.ARG_EMAIL])
                          ? Container(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<String>(
                                onSelected: con.deleteComment,
                                itemBuilder: (context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem(
                                    value: i.toString(),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Delete comment',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.12,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: ClipOval(
                              child: Image.network(
                                comments[i][Constant.ARG_PROFILE_PICTURE_URL],
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Text(
                            '  ${comments[i][Constant.ARG_USERNAME]}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' commented:',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Container(
                          padding: const EdgeInsets.only(left: 60.0),
                          alignment: Alignment.centerLeft,
                          child: Text('${comments[i][Constant.ARG_COMMENT]}')),
                      Divider(color: Colors.black),
                    ]),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _PhotoViewState state;
  _Controller(this.state);
  String comment;

  void goToDetailedView() async {
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_USER_INFO: state.userInfo,
          Constant.ARG_ONE_PHOTOMEMO: state.onePhotoMemo,
        });

    state.render(() {});
  }

  void submitComment() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    try {
      await FirebaseController.uploadComment(
          photoFilename: state.onePhotoMemo.photoFilename,
          userEmail: state.user.email,
          userUid: state.user.uid,
          comment: comment);

      List<dynamic> newCommentList = await FirebaseController.getComments(
          photoFilename: state.onePhotoMemo.photoFilename);

      state.render(() {
        state.comments = newCommentList;
        state.commentInputController.clear();
      });
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Comments upload error',
        content: '$e',
      );
    }
  }

  String validateComment(String value) {
    if (value.length > 0) {
      return null;
    } else {
      return "Comment too short! (min. 1 character)";
    }
  }

  void saveComment(String value) {
    comment = value;
  }

  void deleteComment(String value) async {
    int index = int.parse(value);
    var timestamp = state.comments[index][Constant.ARG_TIMESTAMP];

    try {
      List<dynamic> updatedComments = await FirebaseController.deleteComment(
          photoFilename: state.onePhotoMemo.photoFilename,
          commentTimestamp: timestamp);
      state.render(() => state.comments = updatedComments);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Firestore delete comment error',
        content: '$e',
      );
    }
  }

  void likeHandler() async {
    if (await FirebaseController.likeExists(
        photoFilename: state.onePhotoMemo.photoFilename,
        email: state.user.email)) {
      try {
        List<dynamic> updatedLikes = await FirebaseController.deleteLike(
            photoFilename: state.onePhotoMemo.photoFilename,
            email: state.user.email);
        state.render(() {
          state.likes = updatedLikes;
          state.liked = false;
        });
      } catch (e) {
        MyDialog.info(
          context: state.context,
          title: 'Firestore delete like error',
          content: '$e',
        );
      }
    } else {
      try {
        await FirebaseController.uploadLike(
          photoFilename: state.onePhotoMemo.photoFilename,
          userEmail: state.user.email,
          userUid: state.user.uid,
        );

        List<dynamic> newLikeList = await FirebaseController.getLikes(
            photoFilename: state.onePhotoMemo.photoFilename);

        state.render(() {
          state.likes = newLikeList;
          state.liked = true;
        });
      } catch (e) {
        MyDialog.info(
          context: state.context,
          title: 'Like upload error',
          content: '$e',
        );
      }
    }
  }
}
