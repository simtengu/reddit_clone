import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/core/common/post_card.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/features/posts/controllers/posts_controller.dart';
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(data: (communities)=> ref.watch(userCommunityPostsProvider(communities)).when(data: (posts){
       return ListView.builder(
         itemCount: posts.length,
         itemBuilder: (BuildContext context, int index) {
          final post = posts[index];
           return PostCard(post: post);
         },
       );
    }, error: (error,stackTrace)=> ErrorText(error: error.toString()), loading: ()=> const ScreenLoader())
    , error: (error,stackTrace)=> ErrorText(error: error.toString()), loading: ()=> const ScreenLoader());
  }
}