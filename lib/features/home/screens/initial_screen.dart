import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import 'package:reddit_application/features/home/screens/home_screen.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ref.watch(authUserProvider).when(
            data: (user) {
              if (user == null) {
                return ref.read(authControllerProvider.notifier).signOut();
              }

              return const HomeScreen();
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const ScreenLoader(),
          ),
    );
  }
}
