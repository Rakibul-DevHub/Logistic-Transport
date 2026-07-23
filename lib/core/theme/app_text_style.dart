import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyle {
  AppTextStyle._();


  static TextStyle get BricolageGrotesque_24pt_Regular => const TextStyle(
    fontFamily: 'BricolageGrotesque_24pt-Regular',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
  );


  static TextStyle get SFProDisplay_Regular => const TextStyle(
    fontFamily: 'SFProDisplay-Regular',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
  );
  static TextStyle get SFProDisplay_White => const TextStyle(
    fontFamily: 'SFProDisplay-Regular',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.whiteColor,
  );
  static TextStyle get SFProDisplay_Black => const TextStyle(
    fontFamily: 'SFProDisplay-Regular',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.blackColor,
  );

}