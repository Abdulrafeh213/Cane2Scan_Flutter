import 'package:flutter/material.dart';

// Drawer Section
class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Set the drawer background to white
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/logo.png",
                ), // Replace with your asset
                fit: BoxFit.cover,
              ),
              color: Colors.blueAccent, // Optional: Header background color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
          ListTile(
            leading: Icon(Icons.connect_without_contact, color: Colors.black),
            title: Text(
              "Change IP Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.connect_without_contact, color: Colors.black),
            title: Text(
              "Show IP Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.admin_panel_settings, color: Colors.black),
          //   title: Text(
          //     "Control Panel",
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          //   ),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
        ],
      ),
    );
  }
}
