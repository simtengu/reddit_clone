import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/core/common/post_card.dart';
import 'package:reddit_application/features/posts/controllers/posts_controller.dart';
import 'package:reddit_application/features/posts/widgets/comment_card.dart';
import 'package:reddit_application/theme/pallete.dart';

import '../../../models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  const CommentScreen({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  bool isPostButtonActive = false;

  void addComment() {
    ref.read(postsControllerProvider.notifier).addComment(
        context: context,
        commentBody: commentController.text.trim(),
        postId: widget.postId);
    setState(() {
      commentController.text = "";
      isPostButtonActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ref.watch(getPostByIdProvider(widget.postId)).when(
                data: (post) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCard(post: post),
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Text('Comments')),
                      Container(
                        color: ref.watch(themeNotifierProvider).backgroundColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      isPostButtonActive = false;
                                    });
                                  } else {
                                    setState(() {
                                      isPostButtonActive = true;
                                    });
                                  }
                                },
                                controller: commentController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 6),
                                  border: InputBorder.none,
                                  hintText: 'add your comment..',
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed:
                                    isPostButtonActive ? addComment : () {},
                                child: Text(
                                  'Post',
                                  style: TextStyle(
                                      color: !isPostButtonActive
                                          ? Colors.grey
                                          : Colors.blue),
                                )),
                          ],
                        ),
                      ),
                      ref.watch(getPostCommentsProvider(widget.postId)).when(
                          data: (comments) {
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: comments.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = comments[index];
                                return CommentCard(comment: comment);
                              },
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const ScreenLoader()),
                    ],
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const ScreenLoader()),

            //display post by using future provider...................
            // FutureBuilder<Post>(
            //   future: ref.watch(fetchPostProvider(widget.postId)),
            //   builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const ScreenLoader();
            //     } else if (snapshot.hasError) {
            //       return Text(
            //           'Error: ${snapshot.error}');
            //     } else {
            //       final post = snapshot.data!;
            //       return Column(
            //         children: [
            //           PostCard(post: post),
            //           TextField(
            //             controller: commentController,
            //             decoration: const InputDecoration(
            //               filled: true,
            //               contentPadding:
            //                   EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            //               border: InputBorder.none,
            //               hintText: 'your comment..',
            //             ),
            //           )
            //         ],
            //       );
            //     }
            //   },
            // ),
          ),
        ),
      ),
    );
  }
}
