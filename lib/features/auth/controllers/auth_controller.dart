import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/providers/firebase_providers.dart';
import 'package:reddit_application/core/utilities.dart';
import 'package:reddit_application/features/auth/repositories/auth_repository.dart';
import 'package:reddit_application/models/user_model.dart';

final userProvider = StateProvider<UserModel?>(
  (ref) => null,
);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) {
    return AuthController(
      authRepository: ref.watch(authRepoProvider),
      ref: ref,
    );
  },
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final authUserProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  final authUser = ref.watch(authProvider).currentUser!;
 final rs = await authController.getUserData(authUser.uid).first;
  ref.read(userProvider.notifier).update((state) => rs);
  return rs;
  // final myStream = authController.authStateChange;

  // UserModel? userModel;
  // myStream.first.then((value) async {
  //   if (value != null) {
  //     userModel = await ref
  //         .watch(authControllerProvider.notifier)
  //         .getUserData(value.uid)
  //         .first;
  //   print('value-usermodel $userModel');

  //   }
  // });

  // print('user model : $userModel');
  // return Stream.value(userModel);
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold((l) {
      return showSnackBar(context, l.message);
    },
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold((l) {
      return showSnackBar(context, l.message);
    },
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }

  signOut() async {
    await _authRepository.signOut();
  }

  Stream<UserModel?> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
