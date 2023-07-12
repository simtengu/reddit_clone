import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/enums.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utilities.dart';
import '../repositories/user_profile_repo.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
      storageRepo: ref.watch(storagRepoProvider),
      userProfileRepo: ref.watch(userProfileRepoProvider),
      ref: ref);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepo _userProfileRepo;
  final StorageRepo _storageRepo;
  Ref _ref;
  UserProfileController(
      {required UserProfileRepo userProfileRepo,
      required StorageRepo storageRepo,
      required Ref ref})
      : _userProfileRepo = userProfileRepo,
        _storageRepo = storageRepo,
        _ref = ref,
        super(false);

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    //if new profile pic has been picked by user''' update.....
    if (profileFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'users/profile', id: user.uid, file: profileFile);

      res.fold((l) => showSnackBar(context, l.message),
          (avatarLink) => user = user.copyWith(profilePic: avatarLink));
    }

    //if new banner pic has been picked by user update.....
    if (bannerFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'users/banner', id: user.name, file: bannerFile);

      res.fold((l) => showSnackBar(context, l.message),
          (bannerLink) => user = user.copyWith(banner: bannerLink));
    }

    //update community in firestore.................
    user = user.copyWith(name: name);
    final res = await _userProfileRepo.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  void updateUserKarma(UserKarma userKarma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + userKarma.Karma);
    final res = await _userProfileRepo.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
