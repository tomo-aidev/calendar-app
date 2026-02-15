import 'package:flutter/material.dart';
import '../config/colors.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final double height;

  const GradientHeader({
    super.key,
    required this.title,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        border: Border(
          bottom: BorderSide(color: AppColors.red, width: 2),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
