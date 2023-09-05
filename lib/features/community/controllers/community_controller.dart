import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_application/core/constants/constants.dart';
import 'package:reddit_application/core/failure.dart';
import 'package:reddit_application/core/providers/storage_repository_provider.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/repositories/community_repo.dart';
import 'package:reddit_application/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/utilities.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getUserCommunities();
});

final getAllCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getAllCommunities();
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.searchCommunity(query);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      storageRepo: ref.watch(storagRepoProvider),
      communityRepo: ref.watch(communityRepoProvider),
      ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepo _communityRepo;
  final StorageRepo _storageRepo;
  Ref _ref;
  CommunityController(
      {required CommunityRepo communityRepo,
      required StorageRepo storageRepo,
      required Ref ref})
      : _communityRepo = communityRepo,
        _storageRepo = storageRepo,
        _ref = ref,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepo.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final userId = _ref.read(userProvider)!.uid;
    return _communityRepo.getUserCommunities(userId);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepo.getCommunityByName(name);
  }

  void aditCommunity(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required Community community}) async {
    state = true;
    //if new profile pic has been picked by user update.....
    if (profileFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'communities/profile', id: community.name, file: profileFile);

      res.fold((l) => showSnackBar(context, l.message),
          (avatarLink) => community = community.copyWith(avatar: avatarLink));
    }

    //if new banner pic has been picked by user update.....
    if (bannerFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'communities/banner', id: community.name, file: bannerFile);

      res.fold((l) => showSnackBar(context, l.message),
          (bannerLink) => community = community.copyWith(banner: bannerLink));
    }

    //update community in firestore.................

    final res = await _communityRepo.aditCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  void joinOrLeaveCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepo.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepo.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'You have left community successfully');
      } else {
        showSnackBar(context, 'You have joined community successfully');
      }
    });
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepo.searchCommunity(query);
  }

  addMods(String communityName, List<String> uids, BuildContext context) async {
    final rs = await _communityRepo.addMods(communityName, uids);

    rs.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community moderators list updated');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getAllCommunities() {
    return _communityRepo.getAllCommunities();
  }
}
