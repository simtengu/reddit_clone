import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_application/core/constants/constants.dart';
import 'package:reddit_application/core/constants/firebase_constants.dart';
import 'package:reddit_application/core/failure.dart';
import 'package:reddit_application/core/providers/firebase_providers.dart';
import 'package:reddit_application/core/type_defs.dart';
import 'package:reddit_application/models/user_model.dart';

final authRepoProvider = Provider((ref) {
  return AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _firestore = firestore,
        _auth = auth,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel? userModel;
      userModel = await getUserData(userCredential.user!.uid).first;

      if (userModel == null) {
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'No name',
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);
//create user in users collection in firebase.............
        await _users.doc(userModel.uid).set(userModel.toMap());
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<UserModel?> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      if (event.data() != null) {
        return UserModel.fromMap(event.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
