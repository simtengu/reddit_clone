import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/enums.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/posts/repositories/posts_repo.dart';
import 'package:reddit_application/features/user_profile/controllers/user_profile_controller.dart';
import 'package:reddit_application/models/community_model.dart';
import 'package:reddit_application/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utilities.dart';
import '../../../models/comment_model.dart';

final postsControllerProvider =
    StateNotifierProvider<PostsController, bool>((ref) {
  return PostsController(
      postsRepo: ref.watch(postsRepoProvider),
      storageRepo: ref.watch(storagRepoProvider),
      ref: ref);
});

final userCommunityPostsProvider =
    StreamProvider.family((ref, List<Community> userCommunities) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.fetchUserCommunityPosts(userCommunities);
});

final fetchPostProvider = Provider.family((ref, String postId) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.fetchPost(postId);
});

final userPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.getUserPosts();
});

final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postsControllerProvider.notifier);
  return postController.getPostComments(postId);
});

class PostsController extends StateNotifier<bool> {
  final PostsRepo _postsRepo;
  final StorageRepo _storageRepo;
  Ref _ref;
  PostsController(
      {required PostsRepo postsRepo,
      required StorageRepo storageRepo,
      required Ref ref})
      : _postsRepo = postsRepo,
        _storageRepo = storageRepo,
        _ref = ref,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required Community community,
    required String title,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
        id: postId,
        title: title,
        description: description,
        communityName: community.name,
        communityProfilePic: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: []);

    final res = await _postsRepo.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post Created Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required Community community,
    required String title,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
        id: postId,
        title: title,
        link: link,
        communityName: community.name,
        communityProfilePic: community.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: []);

    final res = await _postsRepo.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post Created Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required Community community,
    required String title,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imgResult = await _storageRepo.storeFile(
        path: 'posts/${community.name}', id: postId, file: file);
    imgResult.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
          id: postId,
          title: title,
          communityName: community.name,
          communityProfilePic: community.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: [],
          link: r);

      final res = await _postsRepo.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;

      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Post Created Successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserCommunityPosts(List<Community> userCommunities) {
    if (userCommunities.isNotEmpty) {
      return _postsRepo.fetchUserCommunityPosts(userCommunities);
    }

    return Stream.value([]);
  }


  Stream<List<Post>> fetchGuestPosts() {
   
      return _postsRepo.fetchGuestPosts();
    

  
  }
//delete the post..................
  void deletePost(BuildContext context, Post post) async {
    final res = await _postsRepo.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Post deleted successfully'));
  }

  void upvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;

    _postsRepo.upvote(post, userId);
  }

  void downvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;

    _postsRepo.downvote(post, userId);
  }

  Stream<List<Post>> getUserPosts() {
    final userId = _ref.read(userProvider)!.uid;

    return _postsRepo.getUserPosts(userId);
  }

  Future<Post> fetchPost(String postId) {
    return _postsRepo.fetchPost(postId);
  }

  Stream<Post> getPostById(String postId) {
    return _postsRepo.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required String commentBody,
      required String postId}) async {
    final user = _ref.read(userProvider)!;
    final comment = Comment(
        id: const Uuid().v1(),
        body: commentBody,
        createdAt: DateTime.now(),
        postId: postId,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postsRepo.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);

    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> getPostComments(String postId) {
    return _postsRepo.getPostComments(postId);
  }


  void awardPost({ required Post post, required String award, required BuildContext context}) async {
    final senderId = _ref.read(userProvider)!.uid;

   final res =  await _postsRepo.awardPost(post, award, senderId);
   res.fold((l) => showSnackBar(context,l.message), (r){
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.awardPost);
    
  Routemaster.of(context).pop();
   });

  }
}
