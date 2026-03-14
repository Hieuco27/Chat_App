import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

class EmojiPickerWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  const EmojiPickerWidget({super.key, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          // Do something when emoji is selected
        },
        onBackspacePressed: () {
          // Do something when backspace is pressed
        },
        textEditingController: textEditingController,
        config: Config(
          height: 256,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax:
                28 *
                (foundation.defaultTargetPlatform ==
                        foundation.TargetPlatform.iOS
                    ? 1.2
                    : 1.0),
          ),
          swapCategoryAndBottomBar: false,
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(),
          bottomActionBarConfig: const BottomActionBarConfig(),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }
}
