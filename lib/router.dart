//logged out..................
import 'package:flutter/material.dart';
import 'package:reddit_application/features/auth/screens/login_screen.dart';
import 'package:reddit_application/features/community/screens/create_screen.dart';
import 'package:reddit_application/features/home/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

//loggedin ...................

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunityScreen()),
});
