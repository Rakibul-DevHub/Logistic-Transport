import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget? child; // optional content inside the background

  const CustomBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/custom_background.png'),
          fit: BoxFit.cover, // covers the whole container
        ),
      ),
      child: child, // place your content on top of the background
    );
  }
}