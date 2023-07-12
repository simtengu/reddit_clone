import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Scaffold.of(context).closeDrawer();
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, String community) {
    Scaffold.of(context).closeDrawer();
    Routemaster.of(context).push('/r/$community');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create a community'),
              onTap: () => navigateToCreateCommunity(context),
            ),
            ref.watch(userCommunitiesProvider).when(
                data: (communities) => Expanded(
                      child: ListView.builder(
                        itemCount: communities.length,
                        itemBuilder: (BuildContext context, int index) {
                          final community = communities[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text('r/${community.name}'),
                            onTap: () {
                              navigateToCommunity(context, community.name);
                            },
                          );
                        },
                      ),
                    ),
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const ScreenLoader())
          ],
        ),
      ),
    );
  }
}
