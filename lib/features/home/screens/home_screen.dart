import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/constants/constants.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_application/features/home/drawers/profile_drawer.dart';
import 'package:reddit_application/theme/pallete.dart';

import '../delegates/search_community_delegate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

    @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();

}

class _HomeScreenState extends ConsumerState<HomeScreen>{
  int _activePage = 0;

  void displayDrawer(BuildContext ctx) {
    Scaffold.of(ctx).openDrawer();
  }

  void displayEndDrawer(BuildContext ctx) {
    Scaffold.of(ctx).openEndDrawer();
  }

  void onPageChanged(int page){
  setState(() {
    _activePage = page;
  });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchCommunityDelegate(ref));
              },
              icon: const Icon(Icons.search)),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () {
                displayEndDrawer(context);
              },
            );
          })
        ],
      ),
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      bottomNavigationBar: CupertinoTabBar(
          onTap: onPageChanged,
          activeColor: currentTheme.iconTheme.color,
          backgroundColor: currentTheme.backgroundColor,
          currentIndex: _activePage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          ]),
      body: Constants.tabWidgets[_activePage],
    );
  }
  

}
