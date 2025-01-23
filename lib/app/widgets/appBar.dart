import 'package:flutter/material.dart';

// AppBar Section
class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (context) => Container(
            height: 56,
            color: Colors.transparent,
            child: AppBar(
              title: Text(
                "Cane2Scan",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 30, // Font size
                  fontWeight: FontWeight.bold, // Font weight
                  fontFamily: 'Roboto', // Optional: Font family
                ),
              ),
              backgroundColor: Colors.blue,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ],
            ),
          ),
    );
  }
}
