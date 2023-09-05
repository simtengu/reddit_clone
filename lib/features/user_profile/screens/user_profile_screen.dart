import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/community/screens/community_screen.dart';
import 'package:reddit_application/features/posts/controllers/posts_controller.dart';
import 'package:reddit_application/features/user_profile/screens/edit_profile_screen.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../models/post_model.dart';
import '../../../theme/pallete.dart';
import '../../auth/controllers/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditProfileScreen(uid: uid,)));
  }

  void deletePost(BuildContext context, WidgetRef ref, Post post) {
    ref.read(postsControllerProvider.notifier).deletePost(context, post);
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CommunityScreen(name: communityName ,)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final getCommunity = ref.watch(getUserDataProvider(uid));
    return Scaffold(
      body: getCommunity.when(
        data: (user) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  expandedHeight: 250,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          user!.banner,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(20).copyWith(bottom: 70),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 35,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(20),
                        child: TextButton.icon(
                          onPressed: () => navigateToEditProfile(context),
                          icon: const Icon(Icons.edit_square),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white54),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'r/${user.name}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('${user.karma} karma'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                    ]),
                  ),
                ),
              ];
            },
            body: ref.watch(userPostsProvider).when(
                data: (posts) {
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];

                      return Container(
                        padding: const EdgeInsets.all(0)
                            .copyWith(bottom: 30, left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => navigateToCommunity(
                                      context, post.communityName),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
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
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (post.type == "image")
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.33,
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
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
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
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const ScreenLoader())),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const ScreenLoader(),
      ),
    );
  }
}
