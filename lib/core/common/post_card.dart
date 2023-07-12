import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/core/constants/constants.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/features/posts/controllers/posts_controller.dart';
import 'package:reddit_application/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../models/post_model.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePostDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Warning',
          ),
          content: const Text(
              'You won\'t be able to restore this post once deleted'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(postsControllerProvider.notifier)
                    .deletePost(context, post);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void awardPost(
    WidgetRef ref,
    BuildContext context,
    String award,
  ) {
    ref
        .read(postsControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void upvotePost(WidgetRef ref) {
    ref.read(postsControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) {
    ref.read(postsControllerProvider.notifier).downvote(post);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == "image";
    final isTypeText = post.type == "text";
    final isTypeLink = post.type == "link";
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4)
                                  .copyWith(bottom: 0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          post.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'r/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUser(context),
                                          child: Text(
                                            'u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (post.uid == user.uid)
                                    IconButton(
                                      onPressed: () =>
                                          deletePostDialog(context, ref),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Pallete.redColor,
                                        size: 17,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final awd = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[awd]!,
                                      height: 20,
                                    );
                                  },
                                ),
                              )
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.34,
                                width: double.infinity,
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: AnyLinkPreview(
                                  link: post.link!,
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding:
                                    const EdgeInsets.only(bottom: 4, left: 10),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => upvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_up,
                                        size: 21,
                                        color: post.upvotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => downvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_down,
                                        size: 21,
                                        color: post.downvotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.downvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToComments(context),
                                      icon: const Icon(
                                        Icons.comment,
                                        size: 21,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                  ),
                                                  itemCount: user.awards.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final award =
                                                        user.awards[index];
                                                    return GestureDetector(
                                                      onTap: () => awardPost(
                                                          ref, context, award),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                            Constants.awards[
                                                                award]!),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.card_giftcard_outlined)),
                                    ref
                                        .watch(getCommunityByNameProvider(
                                            post.communityName))
                                        .when(
                                          data: (community) {
                                            if (community.mods
                                                .contains(user.uid)) {
                                              return Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        deletePostDialog(
                                                            context, ref),
                                                    icon: const Icon(
                                                      Icons
                                                          .admin_panel_settings,
                                                      size: 21,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                  error: error.toString()),
                                          loading: () => const ScreenLoader(),
                                        ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ]),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
