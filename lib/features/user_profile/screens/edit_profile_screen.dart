import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/auth/controllers/auth_controller.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utilities.dart';
import '../../../theme/pallete.dart';
import '../controllers/user_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;

  late TextEditingController nameFieldController;

  @override
  void initState() {
    super.initState();
    nameFieldController =
        TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameFieldController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void updateUser() {
    ref.read(userProfileControllerProvider.notifier).editCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        name: nameFieldController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) {
          return Scaffold(
            backgroundColor: currentTheme.backgroundColor,
            appBar: AppBar(
              title: const Text('Edit User'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: updateUser,
                  child: const Text('Save'),
                ),
              ],
            ),
            body: isLoading ? const ScreenLoader() : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: currentTheme.textTheme.bodyMedium!.color!,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bannerFile != null
                                ? Image.file(bannerFile!)
                                : user!.banner.isEmpty ||
                                        user.banner == Constants.bannerDefault
                                    ? const Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        ),
                                      )
                                    : Image.network(user.banner),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: profileFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(profileFile!),
                                  radius: 32,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user!.profilePic),
                                  radius: 32,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: nameFieldController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Name',
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                )
              ]),
            ),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const ScreenLoader());
  }
}