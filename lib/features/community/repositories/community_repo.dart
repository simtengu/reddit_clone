import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_application/core/constants/firebase_constants.dart';
import 'package:reddit_application/core/failure.dart';
import 'package:reddit_application/core/providers/firebase_providers.dart';
import 'package:reddit_application/core/type_defs.dart';
import 'package:reddit_application/models/community_model.dart';

final communityRepoProvider = Provider((ref) {
  return CommunityRepo(firestore: ref.watch(firestoreProvider));
});

class CommunityRepo {
  final FirebaseFirestore _firestore;
  CommunityRepo({required FirebaseFirestore firestore})
      : _firestore = firestore;

//getters....................
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw "Community with the same name already exists";
      }

      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> userCommunities = [];
      for (var doc in event.docs) {
        userCommunities
            .add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }

      return userCommunities;
    });
  }
}
