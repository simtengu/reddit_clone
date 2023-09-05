import 'package:flutter/material.dart';
import 'package:reddit_application/features/community/screens/add_mods_screen.dart';
import 'package:reddit_application/features/community/screens/edit_community_screen.dart';


class ModToolsScreen extends StatelessWidget {
  const ModToolsScreen({super.key, required this.name});
  final String name;

  void goToEditCommunity(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditCommunityScreen(name: name)));
  }

  void goToAddCommunityModerator(BuildContext context) {
    
     Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddModsScreen(name: name)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () => goToAddCommunityModerator(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Community'),
            onTap: () {
              goToEditCommunity(context);
            },
          ),
        ],
      ),
    );
  }
}
