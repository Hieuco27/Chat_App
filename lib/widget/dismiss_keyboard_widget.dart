import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DismissKeyboardWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;

  const DismissKeyboardWidget({super.key, required this.child, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        onDismiss?.call();
      },
      child: child,
    );
  }
}
