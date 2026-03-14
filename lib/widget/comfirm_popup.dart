import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app/core/text_styles.dart';
import 'package:chat_app/core/app_color.dart';

/// General confirmation popup widget
///
/// A customizable modal dialog for confirmation actions.
/// Based on the Figma design with dark theme and customizable buttons.
class ConfirmationPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? backgroundColor;
  final Color? confirmButtonColor;
  final Color? confirmButtonTextColor;
  final Color? cancelButtonColor;
  final Color? cancelButtonTextColor;
  final double? width;
  final double? borderRadius;
  final bool barrierDismissible;

  const ConfirmationPopup({
    super.key,
    required this.title,
    required this.subtitle,
    this.cancelButtonText = 'Cancel',
    this.confirmButtonText = 'Confirm',
    this.onConfirm,
    this.onCancel,
    this.backgroundColor,
    this.confirmButtonColor,
    this.confirmButtonTextColor,
    this.cancelButtonColor,
    this.cancelButtonTextColor,
    this.width,
    this.borderRadius,
    this.barrierDismissible = true,
  });

  /// Show a general confirmation popup dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String cancelButtonText = 'Cancel',
    String confirmButtonText = 'Confirm',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? backgroundColor,
    Color? confirmButtonColor,
    Color? confirmButtonTextColor,
    Color? cancelButtonColor,
    Color? cancelButtonTextColor,
    double? width,
    double? borderRadius,
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ConfirmationPopup(
        title: title,
        subtitle: subtitle,
        cancelButtonText: cancelButtonText,
        confirmButtonText: confirmButtonText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        backgroundColor: backgroundColor,
        confirmButtonColor: confirmButtonColor,
        confirmButtonTextColor: confirmButtonTextColor,
        cancelButtonColor: cancelButtonColor,
        cancelButtonTextColor: cancelButtonTextColor,
        width: width,
        borderRadius: borderRadius,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // ========== TEMPLATE FUNCTIONS ==========

  /// Template: Logout confirmation popup
  static Future<bool?> showLogout(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Log out',
      subtitle: 'Are you sure you want to log out?',
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Log out',
      confirmButtonColor: AppColors.buttomColor,
      confirmButtonTextColor: Colors.black,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: Delete confirmation popup
  static Future<bool?> showDelete(
    BuildContext context, {
    String? itemName,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Delete ${itemName ?? 'item'}',
      subtitle:
          'Are you sure you want to delete this ${itemName ?? 'item'}? This action cannot be undone.',
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Delete',
      confirmButtonColor: Colors.red,
      confirmButtonTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: Discard changes confirmation popup
  static Future<bool?> showDiscardChanges(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Discard changes',
      subtitle: 'Are you sure you want to discard your changes?',
      cancelButtonText: 'Keep editing',
      confirmButtonText: 'Discard',
      confirmButtonColor: Colors.red,
      confirmButtonTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: Exit confirmation popup
  static Future<bool?> showExit(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Exit',
      subtitle: 'Are you sure you want to exit?',
      cancelButtonText: 'Cancel',
      confirmButtonText: 'Exit',
      confirmButtonColor: AppColors.buttomColor,
      confirmButtonTextColor: Colors.black,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: showPopupUpgradeToPro
  static Future<bool?> showPopupUpgradeToPro(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Save your progress',
      subtitle:
          "You’ve logged 30 entries already.\nSign in to back up your data and keep your timeline safe across devices.",
      cancelButtonText: 'Later',
      confirmButtonText: 'Log in ',
      confirmButtonColor: AppColors.buttomColor,
      confirmButtonTextColor: Colors.black,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: Save confirmation popup
  static Future<bool?> showSave(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Save changes',
      subtitle: 'Do you want to save your changes?',
      cancelButtonText: 'Don\'t save',
      confirmButtonText: 'Save',
      confirmButtonColor: AppColors.buttomColor,
      confirmButtonTextColor: Colors.black,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  static Future<bool?> showDataSyncNotAvailable(
    BuildContext context, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: 'Data sync not available',
      subtitle:
          'This account is already linked to activity on another device. To prevent data conflicts, we can’t merge this account with the existing guest data on this device. Your guest activity will remain available locally, but it won’t be synced to this account.',
      cancelButtonText: 'Switch Account',
      confirmButtonText: 'Try as Guest',
      confirmButtonTextColor: Colors.black,
      confirmButtonColor: AppColors.buttomColor,
      cancelButtonColor: const Color(0xFF0B0B0F),
      cancelButtonTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Template: Custom warning popup
  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    required String subtitle,
    String confirmButtonText = 'Continue',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context,
      title: title,
      subtitle: subtitle,
      cancelButtonText: 'Cancel',
      confirmButtonText: confirmButtonText,
      confirmButtonColor: Colors.orange,
      confirmButtonTextColor: Colors.white,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.h),
      child: Container(
        width: width ?? 310,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: AppTextStyles.titleMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.bodyLarge(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: _OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      onCancel?.call();
                    },
                    text: cancelButtonText,
                    color: cancelButtonColor,
                    textColor: cancelButtonTextColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm Button
                Expanded(
                  child: _FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    text: confirmButtonText,
                    backgroundColor: confirmButtonColor,
                    textColor: confirmButtonTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined button for Cancel action
class _OutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final Color? textColor;

  const _OutlinedButton({
    required this.onPressed,
    required this.text,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = color ?? Colors.white;
    final foregroundColor = textColor ?? Colors.white;

    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: const BorderSide(color: Color(0xFFAAABAD), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

/// Filled button for Confirm action
class _FilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const _FilledButton({
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.buttomColor;
    final fgColor = textColor ?? Colors.black;

    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fgColor,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
