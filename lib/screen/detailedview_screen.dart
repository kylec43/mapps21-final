import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/firebasecontroller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/myview/mydialog.dart';
import 'package:lesson3/screen/myview/myimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';
  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemoOriginal;
  PhotoMemo onePhotoMemoTemp;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

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
    onePhotoMemoOriginal ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoTemp ??= PhotoMemo.clone(onePhotoMemoOriginal);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(icon: Icon(Icons.check), onPressed: con.update)
              : IconButton(icon: Icon((Icons.edit)), onPressed: con.edit),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: con.photoFile == null
                        ? MyImage.network(
                            url: onePhotoMemoTemp.photoURL,
                            context: context,
                          )
                        : Image.file(
                            con.photoFile,
                            fit: BoxFit.fill,
                          ),
                  ),
                  editMode
                      ? Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            color: Colors.blue[100],
                            child: PopupMenuButton<String>(
                              onSelected: con.getPhoto,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: Constant.SRC_CAMERA,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_camera),
                                      Text(Constant.SRC_CAMERA),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: Constant.SRC_GALLERY,
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library),
                                      Text(Constant.SRC_GALLERY),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(
                      height: 1.0,
                    )
                  : Text(
                      progressMessage,
                      style: Theme.of(context).textTheme.headline6,
                    ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                ),
                initialValue: onePhotoMemoTemp.title,
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                enabled: editMode,
                decoration: InputDecoration(
                  hintText: 'Enter memo',
                ),
                initialValue: onePhotoMemoTemp.memo,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                enabled: editMode,
                decoration: InputDecoration(
                  hintText: 'Enter Shared With (email list)',
                ),
                initialValue: onePhotoMemoTemp.sharedWith.join(','),
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
              SizedBox(
                height: 5.0,
              ),
              Constant.DEV
                  ? Text('Image labels generate by ML',
                      style: Theme.of(context).textTheme.bodyText1)
                  : SizedBox(
                      height: 1.0,
                    ),
              Constant.DEV
                  ? Text(onePhotoMemoTemp.imageLabels.join(' | '))
                  : SizedBox(
                      height: 1.0,
                    ),
              SizedBox(height: 15),
              Row(children: [
                Text(
                  'Visibility:',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                editMode
                    ? DropdownButton(
                        value: onePhotoMemoTemp.visibility,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: con.saveVisibility,
                        items: [
                          PhotoMemo.VISIBILITY_PUBLIC,
                          PhotoMemo.VISIBILITY_SHARED_ONLY,
                          PhotoMemo.VISIBILITY_PRIVATE
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }).toList(),
                      )
                    : Text(onePhotoMemoTemp.visibility,
                        style: TextStyle(fontSize: 20)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  _Controller(this.state);
  File photoFile; //camera or gallery

  void update() async {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    try {
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo = {};
      if (photoFile != null) {
        Map photoInfo = await FirebaseController.uploadPhotoFile(
          photo: photoFile,
          filename: state.onePhotoMemoTemp.photoFilename,
          uid: state.user.uid,
          listener: (double message) {
            state.render(() {
              if (message == null)
                state.progressMessage = null;
              else {
                message *= 100;
                state.progressMessage =
                    'Uploading: ' + message.toStringAsFixed(1) + ' %';
              }
            });
          },
        );

        state.onePhotoMemoTemp.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
        state.render(() => state.progressMessage = 'ML image labeler started');
        List<dynamic> labels =
            await FirebaseController.getImageLabels(photoFile: photoFile);
        state.onePhotoMemoTemp.imageLabels = labels;

        updateInfo[PhotoMemo.PHOTO_URL] = photoInfo[Constant.ARG_DOWNLOADURL];
        updateInfo[PhotoMemo.IMAGE_LABELS] = labels;
      }

      //determine updated fields

      if (state.onePhotoMemoOriginal.title != state.onePhotoMemoTemp.title) {
        updateInfo[PhotoMemo.TITLE] = state.onePhotoMemoTemp.title;
      }
      if (state.onePhotoMemoOriginal.memo != state.onePhotoMemoTemp.memo) {
        updateInfo[PhotoMemo.MEMO] = state.onePhotoMemoTemp.memo;
      }
      if (state.onePhotoMemoOriginal.visibility !=
          state.onePhotoMemoTemp.visibility) {
        updateInfo[PhotoMemo.VISIBILITY] = state.onePhotoMemoTemp.visibility;
      }
      if (!listEquals(state.onePhotoMemoOriginal.sharedWith,
          state.onePhotoMemoTemp.sharedWith)) {
        updateInfo[PhotoMemo.SHARED_WITH] = state.onePhotoMemoTemp.sharedWith;
      }

      updateInfo[PhotoMemo.TIMESTAMP] = DateTime.now();

      await FirebaseController.updatePhotoMemo(
          state.onePhotoMemoTemp.docId, updateInfo);

      state.onePhotoMemoOriginal.assign(state.onePhotoMemoTemp);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'Update PhotoMemo error',
          content: '$e');
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void getPhoto(String src) async {
    try {
      PickedFile _photoFile;
      if (src == Constant.SRC_CAMERA) {
        _photoFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _photoFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      if (_photoFile == null) return; //selection canceled
      state.render(() => photoFile = File(_photoFile.path));
    } catch (e) {
      MyDialog.info(
          context: state.context, title: "getPhoto error", content: '$e');
    }
  }

  void saveTitle(String value) {
    state.onePhotoMemoTemp.title = value;
  }

  void saveMemo(String value) {
    state.onePhotoMemoTemp.memo = value;
  }

  void saveSharedWith(String value) {
    if (value.trim().length != 0) {
      state.onePhotoMemoTemp.sharedWith =
          value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }

  void saveVisibility(String value) {
    state.render(() => state.onePhotoMemoTemp.visibility = value);
  }
}
