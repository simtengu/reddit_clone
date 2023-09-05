import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_application/features/posts/screens/add_post_type_screen.dart';
import 'package:reddit_application/theme/pallete.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToPostType(BuildContext context, String type) {
    
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddPostTypeScreen(type: type,)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 120;
    double iconSize = 60;

    final currentTheme = ref.watch(themeNotifierProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to share',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'select a format of your post',
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),
          const SizedBox(
            height: 13,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () => navigateToPostType(context, 'image'),
                    child: SizedBox(
                      height: cardHeightWidth,
                      width: cardHeightWidth,
                      child: Card(
                        color: currentTheme.backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 11,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  const Text(
                    'Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () => navigateToPostType(context, 'text'),
                    child: SizedBox(
                      height: cardHeightWidth,
                      width: cardHeightWidth,
                      child: Card(
                        color: currentTheme.backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 11,
                        child: Center(
                          child: Icon(
                            Icons.edit_note,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  const Text(
                    'Text',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () => navigateToPostType(context, 'link'),
                    child: SizedBox(
                      height: cardHeightWidth,
                      width: cardHeightWidth,
                      child: Card(
                        color: currentTheme.backgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 11,
                        child: Center(
                          child: Icon(
                            Icons.link_outlined,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  const Text(
                    'Link',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
