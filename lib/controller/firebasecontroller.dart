import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirebaseController {
  static Future<User> signIn(
      {@required String email, @required String password}) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());

    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });

    return result;
  }

  static Future<List<dynamic>> getImageLabels(
      {@required File photoFile}) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler =
        FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels =
        await cloudLabeler.processImage(visionImage);
    List<dynamic> labels = <dynamic>[];
    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE)
        labels.add(label.text.toLowerCase());
    }

    return labels;
  }

  static Future<void> updatePhotoMemo(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      if (doc[PhotoMemo.VISIBILITY] == PhotoMemo.VISIBILITY_PUBLIC ||
          doc[PhotoMemo.VISIBILITY] == PhotoMemo.VISIBILITY_SHARED_ONLY) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      }
    });

    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docId)
        .delete();

    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
  }

  static Future<List<PhotoMemo>> searchImage(
      {@required String createdBy, @required List<String> searchLabels}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var results = <PhotoMemo>[];
    querySnapshot.docs.forEach(
        (doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));
    return results;
  }

//===============================================SPRINT 1============================================

  static Future<void> createAccount(
      {@required String email,
      @required String password,
      @required String username,
      @required Function listener,
      profilePicture}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .where(Constant.ARG_USERNAME, isEqualTo: username)
        .get();

    if (querySnapshot.size > 0) {
      throw Exception(Constant.USERNAME_NOT_UNIQUE_ERROR);
    }

    UserCredential result =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = result.user;

    String profilePictureURL;
    if (profilePicture == null) {
      profilePictureURL = await FirebaseStorage.instance
          .ref(
              '${Constant.DEFAULT_PROFILE_PICTURE_FOLDER}/${Constant.DEFAULT_PROFILE_PICTURE_NAME}')
          .getDownloadURL();
    } else {
      Map photoInfo = await uploadPhotoFile(
        photo: profilePicture,
        uid: user.uid,
        listener: listener,
        filename:
            '${Constant.PROFILE_PICTURES_FOLDER}/${user.uid}/${DateTime.now()}',
      );

      await addProfilePicture(email: user.email, profilePictureInfo: photoInfo);

      profilePictureURL = photoInfo[Constant.ARG_DOWNLOADURL];
    }

    await user.updateProfile(
        displayName: username, photoURL: profilePictureURL);

    await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .add(<String, dynamic>{
      Constant.ARG_USERNAME: username,
      Constant.ARG_OWNER: user.email
    });
  }

  static Future<String> addProfilePicture(
      {@required String email,
      @required Map<String, String> profilePictureInfo}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_PICTURES_COLLECTION)
        .where(Constant.ARG_OWNER, isEqualTo: email)
        .get();

    var ref;
    String docId;
    if (querySnapshot.size == 0) {
      ref = await FirebaseFirestore.instance
          .collection(Constant.PROFILE_PICTURES_COLLECTION)
          .add({
        Constant.ARG_OWNER: email,
        Constant.ARG_FILENAME: profilePictureInfo[Constant.ARG_FILENAME]
      });
      docId = ref.id;
    } else {
      querySnapshot.docs.forEach((doc) {
        docId = doc.id;
      });
      await FirebaseFirestore.instance
          .collection(Constant.PROFILE_PICTURES_COLLECTION)
          .doc(docId)
          .update({
        Constant.ARG_FILENAME: profilePictureInfo[Constant.ARG_FILENAME]
      });
    }
    return docId;
  }

  static Future<void> sendResetEmail(email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> changeUsername(
      {@required user, @required newUsername}) async {
    QuerySnapshot querySnapShot = await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .where(Constant.ARG_USERNAME, isEqualTo: newUsername)
        .get();

    if (querySnapShot.size > 0) {
      throw Exception(Constant.USERNAME_NOT_UNIQUE_ERROR);
    }

    querySnapShot = await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .where(Constant.ARG_OWNER, isEqualTo: user.email)
        .get();

    String docId = '';
    querySnapShot.docs.forEach((doc) {
      docId = doc.id;
    });

    await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .doc(docId)
        .update({Constant.ARG_USERNAME: newUsername});

    await user.updateProfile(displayName: newUsername);
  }

  static Future<void> changeEmail({@required user, @required newEmail}) async {
    String oldEmail = user.email;
    await user.updateEmail(newEmail);
    await updateEmailInFirestore(oldEmail: oldEmail, newEmail: newEmail);
  }

  static Future<void> changePassword(
      {@required user, @required String newPassword}) async {
    await user.updatePassword(newPassword);
  }

  static User getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<void> changeProfilePicture(
      {@required User user,
      @required File photo,
      @required Function listener}) async {
    QuerySnapshot querySnapShot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_PICTURES_COLLECTION)
        .where(Constant.ARG_OWNER, isEqualTo: user.email)
        .get();

    String filename =
        '${Constant.PROFILE_PICTURES_FOLDER}/${user.uid}/${DateTime.now()}';

    String defaultProfilePictureURL = await FirebaseStorage.instance
        .ref(
            '${Constant.DEFAULT_PROFILE_PICTURE_FOLDER}/${Constant.DEFAULT_PROFILE_PICTURE_NAME}')
        .getDownloadURL();

    if (user.photoURL != defaultProfilePictureURL) {
      querySnapShot.docs.forEach((doc) {
        filename = doc[Constant.ARG_FILENAME];
      });
    }

    Map photoInfo = await uploadPhotoFile(
        photo: photo, filename: filename, uid: user.uid, listener: listener);
    await addProfilePicture(email: user.email, profilePictureInfo: photoInfo);

    await user.updateProfile(photoURL: photoInfo[Constant.ARG_DOWNLOADURL]);
  }

  static Future<void> updateEmailInFirestore(
      {@required oldEmail, @required newEmail}) async {
    //Update profile picture owner to new email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE_PICTURES_COLLECTION)
        .where(Constant.ARG_OWNER, isEqualTo: oldEmail)
        .get();

    String docId;
    if (querySnapshot.size != 0) {
      querySnapshot.docs.forEach((doc) {
        docId = doc.id;
      });
      await FirebaseFirestore.instance
          .collection(Constant.PROFILE_PICTURES_COLLECTION)
          .doc(docId)
          .update({Constant.ARG_OWNER: newEmail});
    }

    //Update username owner to new email
    querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.USERNAME_COLLECTION)
        .where(Constant.ARG_OWNER, isEqualTo: oldEmail)
        .get();

    if (querySnapshot.size != 0) {
      querySnapshot.docs.forEach((doc) {
        docId = doc.id;
      });
      await FirebaseFirestore.instance
          .collection(Constant.USERNAME_COLLECTION)
          .doc(docId)
          .update({Constant.ARG_OWNER: newEmail});
    }

    //update shared with email to new email
    querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: oldEmail)
        .get();

    var docIds = <String>[];
    var newSharedWith = <dynamic>[];
    if (querySnapshot.size != 0) {
      querySnapshot.docs.forEach((doc) {
        List<dynamic> sharedEmails = doc[PhotoMemo.SHARED_WITH];
        var index = sharedEmails.indexOf(oldEmail);

        sharedEmails[index] = newEmail;
        newSharedWith.add(sharedEmails);
        docIds.add(doc.id);
      });

      for (int i = 0; i < docIds.length; i++) {
        print(docIds[i]);
        print(newSharedWith[i]);
        await FirebaseFirestore.instance
            .collection(Constant.PHOTOMEMO_COLLECTION)
            .doc(docIds[i])
            .update({PhotoMemo.SHARED_WITH: newSharedWith[i]});
      }
    }
  }
}
