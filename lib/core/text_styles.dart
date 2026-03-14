import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

/// Custom text styles for the app
class AppTextStyles {
  AppTextStyles._();

  // Display styles (largest)
  static TextStyle displayLarge() {
    return GoogleFonts.inter(fontSize: 57.sp, fontWeight: FontWeight.w400);
  }

  static TextStyle displayMedium() {
    return GoogleFonts.inter(fontSize: 45.sp, fontWeight: FontWeight.w400);
  }

  static TextStyle displayMediumBold() {
    return GoogleFonts.inter(
      fontSize: 45.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle displaySmall() {
    return GoogleFonts.inter(fontSize: 36.sp, fontWeight: FontWeight.w400);
  }

  // Headline styles
  static TextStyle headlineLarge() {
    return GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineMedium() {
    return GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle headlineSmall() {
    return GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w600);
  }

  // Title styles
  static TextStyle titleLarge() {
    return GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600);
  }

  static TextStyle titleLargeDiaLog() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMediumBlack() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.cardPanel,
    );
  }

  static TextStyle titleMedium() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMediumLogin() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMediumGetStart() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.backgroundLogin,
    );
  }

  static TextStyle titleSmall() {
    return GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500);
  }

  static TextStyle titleSmall2() {
    return GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w400);
  }

  static TextStyle titleMediumIcon() {
    return GoogleFonts.inter(
      fontSize: 19.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMedium16() {
    return GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500);
  }

  // Label styles
  static TextStyle labelLarge() {
    return GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500);
  }

  static TextStyle labelMedium() {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle labelSmall() {
    return GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w500);
  }

  // Body styles
  static TextStyle bodyLarge() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyLargeEmphasized() {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.colorEmphasized,
    );
  }

  static TextStyle bodyMedium() {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
    );
  }

  static TextStyle bodySmall() {
    return GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 16 / 12,
    );
  }
}
