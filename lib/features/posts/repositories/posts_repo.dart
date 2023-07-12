import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_application/core/constants/firebase_constants.dart';

import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';
import '../../../models/comment_model.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';

final postsRepoProvider = Provider((ref) {
  return PostsRepo(firestore: ref.watch(firestoreProvider));
});

class PostsRepo {
  final FirebaseFirestore _firestore;
  PostsRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);


CollectionReference get _comments => _firestore.collection(FirebaseConstants.commentsCollection);
  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserCommunityPosts(List<Community> userCommunities) {
    return _posts
        .where('communityName',
            whereIn: userCommunities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String uid) async {
    
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
    }

    if (!(post.upvotes.contains(uid))) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  void downvote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
    }

    if (!(post.downvotes.contains(uid))) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([uid])
      });
    }
  }


  Stream<List<Post>> getUserPosts(String  userId){
     return _posts.where('uid', isEqualTo: userId).snapshots().map((event){
      List<Post> posts = [];
      if (event.docs.isEmpty) {
        return [];
      }
      for (var doc in event.docs) {
        Post post = Post.fromMap(doc.data() as Map<String,dynamic>);
        posts.add(post);
      }

      return posts;
     });
  }





Future<Post> fetchPost(String postId) async {
  Post? post;
  try {
    final  snapshot =  await _posts.doc(postId).get();
      
    if (snapshot.exists) {


      post = Post.fromMap(snapshot.data() as Map<String,dynamic>);
      return post;
      
    } else {
      throw Exception('Post wasn\'t found');
    }
  } on FirebaseException catch(e){
    throw Exception(e.message);

  }
   catch (e) {
    throw e.toString();
    
  }
}



Stream<Post> getPostById(String postId){
    return _posts.doc(postId).snapshots().map((event) => Post.fromMap(event.data() as Map<String,dynamic>));
}



  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_posts.doc(comment.postId).update({'commentCount': FieldValue.increment(1)}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  Stream<List<Comment>> getPostComments(String  postId){
     return _comments.where('postId', isEqualTo: postId).orderBy('createdAt', descending: true).snapshots().map((event){
      List<Comment> comments = [];
      for (var doc in event.docs) {
        Comment comment = Comment.fromMap(doc.data() as Map<String,dynamic>);
        comments.add(comment);
      }

      return comments;
     });
  }



    FutureVoid awardPost(Post post,String award, String senderId) async {
    try {
      
      return right(_posts.doc(post.id).update({'awards': FieldValue.arrayUnion([award])}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


}
