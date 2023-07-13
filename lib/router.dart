//logged out..................
import 'package:flutter/material.dart';
import 'package:reddit_application/features/auth/screens/login_screen.dart';
import 'package:reddit_application/features/community/screens/add_mods_screen.dart';
import 'package:reddit_application/features/community/screens/create_screen.dart';
import 'package:reddit_application/features/community/screens/edit_community_screen.dart';
import 'package:reddit_application/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_application/features/home/screens/home_screen.dart';
import 'package:reddit_application/features/posts/screens/add_post_type_screen.dart';
import 'package:reddit_application/features/posts/screens/comment_screen.dart';
import 'package:reddit_application/features/user_profile/screens/edit_profile_screen.dart';
import 'package:routemaster/routemaster.dart';
import 'features/community/screens/community_screen.dart';
import 'features/home/screens/initial_screen.dart';
import 'features/user_profile/screens/user_profile_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

//loggedin ...................

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: InitialScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (routeData) => MaterialPage(
          child: CommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/add-mods/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
        type: routeData.pathParameters['type']!,
      )),
  '/post/:postId/comments': (routeData) => MaterialPage(
        child: CommentScreen(
          postId: routeData.pathParameters['postId']!,
        ),
      ),
});
