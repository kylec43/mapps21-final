import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/myview/mydialog.dart';

class ChangeProfilePictureScreen extends StatefulWidget {
  static const routeName = '/changeProfilePictureScreen';
  @override
  State<StatefulWidget> createState() {
    return _ChangeProfilePictureState();
  }
}

class _ChangeProfilePictureState extends State<ChangeProfilePictureScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User user;
  Map args;
  File photo;
  String progressMessage;

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
          title: Text('Change Profile Picture'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 25.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: photo == null
                      ? ClipOval(
                          child: Image.network(
                            user.photoURL,
                            fit: BoxFit.fill,
                          ),
                        )
                      : ClipOval(
                          child: Image.file(
                            photo,
                            fit: BoxFit.fill,
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, //Center Row contents horizontally,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () => con.getPhoto(Constant.SRC_CAMERA),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera),
                          Text("Camera"),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.0),
                    RaisedButton(
                      onPressed: () => con.getPhoto(Constant.SRC_GALLERY),
                      child: Row(
                        children: [
                          Icon(Icons.photo_library),
                          Text("Gallery"),
                        ],
                      ),
                    ),
                  ],
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
                progressMessage == null
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(
                        progressMessage,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                SizedBox(
                  height: 15.0,
                ),
                RaisedButton(
                  onPressed: con.changeProfilePicture,
                  child: Text(
                    'Change profile picture',
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
  _ChangeProfilePictureState state;
  _Controller(this.state);
  String newUsername;
  String errorMessage;

  void changeProfilePicture() async {
    if (state.photo == null) {
      return;
    }

    MyDialog.circularProgressStart(state.context);

    try {
      await FirebaseController.changeProfilePicture(
        user: state.user,
        photo: state.photo,
        listener: (double progress) {
          state.render(() {
            if (progress == null)
              state.progressMessage = null;
            else {
              progress *= 100;
              state.progressMessage = 'Uploading profile picture: ' +
                  progress.toStringAsFixed(1) +
                  ' %';
            }
          });
        },
      );

      MyDialog.circularProgressStop(state.context);

      User user = FirebaseController.getCurrentUser();
      state.render(() => state.args[Constant.ARG_USER] = user);

      MyDialog.info(
        context: state.context,
        title: 'Success',
        content: 'Your profile picture has been changed successfully',
        onPressed: () {
          Navigator.of(state.context).pop();
        },
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);

      state.render(() => errorMessage = '$e');
    }
  }

  void getPhoto(String src) async {
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }

      if (_imageFile == null) return; //selection canceled
      state.render(() => state.photo = File(_imageFile.path));
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: 'Failed to get picture',
          content: '$e');
    }
  }

  Future<bool> goBack() async {
    Navigator.pop(state.context);
    return true;
  }
}
