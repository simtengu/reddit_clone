import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/user_profile/screens/user_profile_screen.dart';
import 'package:reddit_application/theme/pallete.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signOut();
  }

  void navigateToUserProfile(BuildContext context, String userId) {
   
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserProfileScreen(uid: userId,)));
  }

  void toggleTheme(WidgetRef ref) {
    ref.watch(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              user.profilePic,
            ),
            radius: 70,
          ),
          const SizedBox(
            height: 17,
          ),
          Text(
            user.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            onTap: () {
              navigateToUserProfile(context, user.uid);
            },
            title: const Text('My Profile'),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Pallete.redColor,
            ),
            title: const Text('Log Out'),
            onTap: () {
              logOut(ref);
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Switch.adaptive(
            value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark,
            onChanged: (value) => toggleTheme(ref),
          ),
        ],
      )),
    );
  }
}
