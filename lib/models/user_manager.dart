import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:lojavirtual/helpers/firebase_erros.dart';
import 'package:lojavirtual/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserManager extends ChangeNotifier {

  UserManager(){
    _loadCurrentUser();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;

  User user;

  bool _loading = false;
  bool get loading => _loading;
  bool get isLoggedIn => user != null;


  Future<void> signIn({User user, Function onFail, Function onSucess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.signInWithEmailAndPassword(
          email: user.email, password: user.password);

      await _loadCurrentUser(firebaseUser: result.user);

      onSucess();
    } on PlatformException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  Future<void> facebookLogin({Function onFail, Function onSuccess}) async {

    loading = true;

    final result = await FacebookLogin().logIn(['email', 'public_profile']);

    switch(result.status){
      case FacebookLoginStatus.loggedIn:
        final credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token
        );

        final authResult = await auth.signInWithCredential(credential);

        if(authResult.user != null){
          final firebaseUser = authResult.user;

          user = User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName,
              email: firebaseUser.email
          );

          await user.saveData();
          user.saveToken();

          onSuccess();
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        onFail(result.errorMessage);
        break;
    }

    loading = false;

  }

  Future<void> googleLogin({Function onFail, Function onSuccess}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'openid',
      ],
    );

    loading = true;

    try {
      await googleSignIn.signIn();
      final result = googleSignIn.currentUser;
      print(result);
      user = User(
          id: result.id,
          name: result.displayName,
          email: result.email
      );

      await user.saveData();
      user.saveToken();
      onSuccess();
      loading = false;

    } catch (e){
      onFail(e.toString());
      print(e);
      loading = false;
    }

  }



  Future<void> signUP({User user, Function onFail, Function onSucess}) async {
    loading = true;
    try {
      final AuthResult result = await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);

      user.id = result.user.uid;
      this.user = user;

      await user.saveData();
      user.saveToken();

      onSucess();
    } on PlatformException catch (e) {
      onFail(getErrorString(e.code));
    }
    loading = false;
  }

  set loading(bool value){
    _loading = value;
    notifyListeners();
  }

  void signOut() {
    auth.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> _loadCurrentUser({FirebaseUser firebaseUser}) async{
    final FirebaseUser currentUser = firebaseUser ?? await auth.currentUser();
    if(currentUser != null){
      final DocumentSnapshot docUser = await firestore.collection('users')
          .document(currentUser.uid).get();
      user = User.fromDocument(docUser);
      user.saveToken();

      final docAdmin = await firestore.collection('admins').document(user.id).get();
      if(docAdmin.exists){
        user.admin = true;
      }

      notifyListeners();
    }
  }

  bool get adminEnabled => user != null && user.admin;


}


