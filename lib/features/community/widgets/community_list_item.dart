import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/community/screens/community_screen.dart';
import 'package:reddit_application/models/community_model.dart';
import 'package:reddit_application/theme/pallete.dart';


class CommunityListItem extends ConsumerWidget {
  final Community community;
  const CommunityListItem({super.key, required this.community});
  void navigateToCommunity(BuildContext context) {
    Scaffold.of(context).closeDrawer();


     Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CommunityScreen(name: community.name)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeNotifierProvider.notifier);
    final size = MediaQuery.of(context).size.width * 0.15;
    return InkWell(
      onTap: () => navigateToCommunity(context),
      child: Card(
        color: theme.mode == ThemeMode.light
            ? const Color.fromARGB(255, 239, 234, 234)
            : Colors.grey,
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      10.0), // Set the desired border radius value
                  child: Image.network(
                    community.avatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                      '${community.members.length} member${community.members.length > 1 ? "s" : ""}')
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_circle_right)
            ],
          ),
        ),
      ),
    );
  }
}
