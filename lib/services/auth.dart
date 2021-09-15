// 認証
// Firebase Authentication の email/password 認証を使用する。
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polesearcherapp/models/user.dart';

class Auth {
  final FirebaseAuth fa = FirebaseAuth.instance;

  // signIn は、メールアドレスとパスワードの組でログインを行います。
  Future<LoginUser> signIn(String email, String password) async {
    final result =
      await fa.signInWithEmailAndPassword(email: email, password: password);
    return LoginUser.fromFirebaseUser(result.user);
  }

  // getUser は、ログインユーザの情報を取得します。
  Future<LoginUser> getUser() async {
    final user = fa.currentUser;
    return LoginUser.fromFirebaseUser(user);
  }

  // signOut はログアウトを行います。
  Future<void> signOut() async {
    return fa.signOut();
  }

  // sendEmailVerification はメールアドレスの認証を行います。
  Future<void> sendEmailVerification() async {
    final user = fa.currentUser;
    await user.sendEmailVerification();
  }

  // isEmailVerified はメールアドレスが認証されているかどうかを返します。
  Future<bool> isEmailVerified() async {
    final user = fa.currentUser;
    return user.emailVerified;
  }

  // reauthenticateWithCredential はユーザ再認証を行います。
  Future<UserCredential> reauthenticateWithCredential(
      String email, String password) async {
    final user = fa.currentUser;
    final credential = EmailAuthProvider.credential(
        email: email, password: password);
    final result = await user.reauthenticateWithCredential(credential);
    return result;
  }

  // updatePassword はパスワードの変更を行います。
  Future<void> updatePassword(String password) async {
    final user = fa.currentUser;
    return user.updatePassword(password);
  }

  // sendPasswordResetEmail はパスワード再発行メールを送信します。
  Future<void> sendPasswordResetEmail(String email) async {
    return fa.sendPasswordResetEmail(email: email);
  }

}
