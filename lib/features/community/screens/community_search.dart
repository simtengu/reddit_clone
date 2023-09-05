import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/features/community/screens/community_screen.dart';
import 'package:routemaster/routemaster.dart';

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  String searchTerm = "";
  // navigate go community....................
  void navigateToCommunity(BuildContext context, String community) {
    
           Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommunityScreen(
             name: community,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(bottom: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                      maxLines: 1,
                      style: const TextStyle(fontSize: 20),
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: 'Search community.....',
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          prefixIcon: IconButton(
                            onPressed: () {
                              Routemaster.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                searchTerm = "";
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          border: InputBorder.none),
                    ),
                  )
                ],
              ),
              if (searchTerm.isNotEmpty)
                Expanded(
                  child: ref.watch(searchCommunityProvider(searchTerm)).when(
                      data: (communities) {
                        if (communities.isNotEmpty) {
                          return ListView.builder(
                            itemCount: communities.length,
                            itemBuilder: (BuildContext context, int index) {
                              final community = communities[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(community.avatar),
                                ),
                                title: Text('r/${community.name}'),
                                onTap: () {
                                  navigateToCommunity(context, community.name);
                                },
                              );
                            },
                          );
                        }
                        return const Center(
                          child: Text("No community was found"),
                        );
                      },
                      error: ((error, stackTrace) => ErrorText(
                            error: error.toString(),
                          )),
                      loading: () => const ScreenLoader()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
