import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key, required this.name});

  final String name;

  void goToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

void joinOrLeaveCommunity(WidgetRef ref,Community community,BuildContext context){
  ref.read(communityControllerProvider.notifier).joinOrLeaveCommunity(community, context);
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final getCommunity = ref.watch(getCommunityByNameProvider(name));
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    child: const Text('Mod tools'),
                                  )
                                : OutlinedButton(
                                    onPressed: () {
                                      joinOrLeaveCommunity(ref,community,context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
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
              body: const Text('here we are')),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const ScreenLoader()),
    );
 
 
  }
}
