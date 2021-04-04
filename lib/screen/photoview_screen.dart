import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/screen/detailedview_screen.dart';
import 'package:lesson3/screen/myview/myimage.dart';

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
  PhotoMemo onePhotoMemo;
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
    user ??= args[Constant.ARG_USER];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
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
              : null,
        ],
      ),
      body: Card(
        elevation: 7.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created By: ${onePhotoMemo.createdBy}'),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: MyImage.network(
                  url: onePhotoMemo.photoURL,
                  context: context,
                ),
              ),
            ),
            Text(
              'Title: ${onePhotoMemo.title}',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text('${onePhotoMemo.memo}'),
            Text('Updated At: ${onePhotoMemo.timestamp}'),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _PhotoViewState state;
  _Controller(this.state);

  void goToDetailedView() async {
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_ONE_PHOTOMEMO: state.onePhotoMemo,
        });

    state.render(() {});
  }
}
