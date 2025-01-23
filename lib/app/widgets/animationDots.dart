import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/home/controllers/home_controller.dart';

class AnimatedDots extends StatelessWidget {
  const AnimatedDots({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller for managing the state
    final HomeController controller = Get.put(HomeController());

    return Obx(() {
      String dots =
          '.' * controller.dotCount.value; // Create the dots animation
      return Text(dots, style: TextStyle(fontSize: 80, color: Colors.blue));
    });
  }
}
