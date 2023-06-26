import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/constants/constants.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/repositories/community_repo.dart';
import 'package:reddit_application/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/utilities.dart';

final userCommunitiesProvider = StreamProvider((ref)  {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getUserCommunities();
});

final communityControllerProvider = StateNotifierProvider<CommunityController,bool>((ref) {
  return CommunityController(communityRepo: ref.watch(communityRepoProvider), ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepo _communityRepo;
  Ref _ref;
  CommunityController({required CommunityRepo communityRepo, required Ref ref})
      : _communityRepo = communityRepo,
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
  res.fold((l) => showSnackBar(context,l.message), (r){
    showSnackBar(context,'Community created successfully');
    Routemaster.of(context).pop();
  });

  }


  Stream<List<Community>> getUserCommunities(){
   final userId = _ref.read(userProvider)!.uid;
   return _communityRepo.getUserCommunities(userId);

}


}
