import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/core/common/error_text.dart';
import 'package:reddit_application/core/common/loader.dart';
import 'package:reddit_application/features/community/controllers/community_controller.dart';
import 'package:reddit_application/models/community_model.dart';

import '../../../core/utilities.dart';
import '../../../theme/pallete.dart';
import '../controllers/posts_controller.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postsControllerProvider.notifier).shareImagePost(
          context: context,
          community: selectedCommunity ?? communities[0],
          title: titleController.text.trim(),
          file: bannerFile);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postsControllerProvider.notifier).shareTextPost(
            context: context,
            community: selectedCommunity ?? communities[0],
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postsControllerProvider.notifier).shareLinkPost(
            context: context,
            community: selectedCommunity ?? communities[0],
            title: titleController.text.trim(),
            link: linkController.text.trim(),
          );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Warning',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Make sure you have filled all fields'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {},
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postsControllerProvider);
    final isTypeImage = widget.type == "image";
    final isTypeText = widget.type == "text";
    final isTypeLink = widget.type == "link";
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text("Post"),
          ),
        ],
      ),
      body: isLoading
          ? const ScreenLoader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter title here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (isTypeImage)
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
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter description here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter a link here...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Select Community')),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;
                          if (communities.isEmpty) {
                            return const SizedBox();
                          }
                          return Align(
                            alignment: Alignment.topLeft,
                            child: DropdownButton(
                              value: selectedCommunity ?? data[0],
                              items: data.map((community) {
                                return DropdownMenuItem(
                                    value: community,
                                    child: Text(community.name));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCommunity = value;
                                });
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const ScreenLoader(),
                      ),
                ],
              ),
            ),
    );
  }
}
