import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_application/features/posts/controllers/posts_controller.dart';
import 'package:reddit_application/models/community_model.dart';

import '../../../models/post_model.dart';
import '../../../theme/pallete.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key, required this.name});

  final String name;

  void goToModTools(BuildContext context) {
   
       Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ModToolsScreen(
              name:name,
            )));
  }

  void joinOrLeaveCommunity(
      WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinOrLeaveCommunity(community, context);
  }

  void deletePost(BuildContext context, WidgetRef ref, Post post) {
    ref.read(postsControllerProvider.notifier).deletePost(context, post);
  }

  void navigateToCommunity(BuildContext context, String communityName) {


           Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommunityScreen(
              name: communityName,
            )));
 
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commName = name.replaceAll("-", " ");

    final user = ref.watch(userProvider)!;
    // print('passed name $name');
    final getCommunity = ref.watch(getCommunityByNameProvider(commName));
    return Scaffold(
      body: getCommunity.when(
          data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      expandedHeight: 150,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'r/${community.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 19),
                              ),
                              community.mods.contains(user.uid)
                                  ? OutlinedButton(
                                      onPressed: () => goToModTools(context),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: const Text('Mod tools'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () {
                                        joinOrLeaveCommunity(
                                            ref, community, context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                          community.members.contains(user.uid)
                                              ? 'Joined'
                                              : 'Join'),
                                    ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                                "${community.members.length} member${community.members.length > 1 ? 's' : ''}"),
                          ),
                        ]),
                      ),
                    ),
                  ];
                },
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Posts"),
                    const SizedBox(
                      height: 10,
                    ),
                    ref.watch(getCommunityPostsProvider(community.name)).when(
                        data: (posts) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (BuildContext context, int index) {
                                final post = posts[index];

                                return Container(
                                  padding: const EdgeInsets.all(0)
                                      .copyWith(bottom: 30, right: 5, left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => navigateToCommunity(
                                                context, post.communityName),
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  post.communityProfilePic),
                                              radius: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () =>
                                                deletePost(context, ref, post),
                                            icon: Icon(
                                              Icons.delete,
                                              color: Pallete.redColor,
                                              size: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6.0,
                                        ),
                                        child: Text(
                                          post.title,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (post.type == "image")
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.33,
                                          width: double.infinity,
                                          child: Image.network(
                                            post.link!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (post.type == "link")
                                        SizedBox(
                                          height: 150,
                                          width: double.infinity,
                                          child: AnyLinkPreview(
                                            link: post.link!,
                                            displayDirection: UIDirection
                                                .uiDirectionHorizontal,
                                          ),
                                        ),
                                      if (post.type == "text")
                                        Container(
                                          alignment: Alignment.bottomLeft,
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            post.description!,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const ScreenLoader()),
                  ],
                ),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const ScreenLoader()),
    );
  }
}
