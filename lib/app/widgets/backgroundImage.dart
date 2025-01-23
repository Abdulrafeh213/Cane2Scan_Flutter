import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // image: DecorationImage(
        //   image: AssetImage(
        //     "assets/images/background_image.jpg",
        //   ), // Replace with your asset
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}
