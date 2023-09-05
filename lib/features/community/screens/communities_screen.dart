import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/features/community/widgets/community_list_item.dart';


class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    
    return Container(
        padding: const EdgeInsets.all(1),
        child: ref.watch(getAllCommunitiesProvider).when(
            data: (communities) {
              if (communities.isEmpty) {
                return const Center(
                  child: Text('No Community Found'),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "All Communities",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ...communities
                          .map((community) =>
                              CommunityListItem(community: community))
                          .toList(),
                    ],
                  ),
                ),
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const ScreenLoader()));
  }
}
