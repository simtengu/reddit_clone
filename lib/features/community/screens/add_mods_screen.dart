import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int counter = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods(){
    ref.read(communityControllerProvider.notifier).addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done_outline_rounded),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (BuildContext context, int index) {
                  final memberId = community.members[index];
                  return ref.watch(getUserDataProvider(memberId)).when(
                        data: (user) {
                          if (community.mods.contains(memberId) &&
                              counter == 0) {
                            uids.add(memberId);
                          }
                          counter++;
                          return CheckboxListTile(
                            value: uids.contains(user!.uid),
                            onChanged: (value) {
                              if (value!) {
                                addUid(user.uid);
                              } else {
                                removeUid(user.uid);
                              }
                            },
                            title: Text(user!.name),
                          );
                        },
                        error: (error, trackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const ScreenLoader(),
                      );
                },
              ),
          error: (error, trackTrace) => ErrorText(error: error.toString()),
          loading: () => const ScreenLoader()),
    );
  }
}
