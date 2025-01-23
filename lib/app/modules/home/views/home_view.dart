import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../widgets/animationDots.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final HomeController controller = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth / 2.9;
    return Scaffold(
      appBar: AppBar(
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
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Foreground with AppBar and Body
          SafeArea(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),

                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: Obx(
                        () =>
                            controller.selectedFile.value == null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  // Set the desired border radius
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height:
                                        MediaQuery.of(context).size.height /
                                        2.4,
                                    fit: BoxFit.fill,
                                  ),
                                )
                                : controller.isUploading.value
                                ? CircularProgressIndicator()
                                : controller.resultImage.value != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    controller.resultImage.value!,
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    fit: BoxFit.fill,
                                  ),
                                )
                                : Container(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),

                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.9,
                    child: SingleChildScrollView(
                      child: Obx(
                        () =>
                            controller.selectedFile.value == null
                                ? Center(
                                  child: Text(
                                    "Welcome to Cane2Scan\n Please select image for process",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : controller.isUploading.value
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Please Wait\n your image is being processed",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Add some space between the text and the dots
                                    AnimatedDots(),
                                  ],
                                )
                                : controller.resultImage.value != null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Obx(
                                      () => SizedBox(
                                        height: 110, // Adjust height as needed
                                        child: PageView.builder(
                                          controller: PageController(
                                            viewportFraction: 0.3,
                                          ),
                                          // Adjust for spacing
                                          itemCount:
                                              controller.croppedImages.length,
                                          itemBuilder: (context, index) {
                                            final base64Image =
                                                controller.croppedImages[index];
                                            final imageBytes = base64Decode(
                                              base64Image,
                                            );
                                            return GestureDetector(
                                              onTap: () {
                                                // Show full-screen image when tapped
                                                _showFullScreenImage(
                                                  context,
                                                  imageBytes,
                                                );
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.memory(
                                                    imageBytes,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        'Status: ${controller.status.value}',
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        'Confidence: ${controller.confidence.value}',
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        'WLD Count: ${controller.wldCount.value}',
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        'Processing Time: ${controller.processingTime.value}',
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Obx(
                                      () => Text(
                                        'Model: ${controller.modelDetections[0]}',
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        'Model: ${controller.modelDetections[1]}',
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        'Model: ${controller.modelDetections[2]}',
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        'Model: ${controller.modelDetections[3]}',
                                      ),
                                    ),

                                    // Obx(
                                    //   () => ListView.builder(
                                    //     itemCount:
                                    //         controller.modelDetections.length,
                                    //     itemBuilder: (context, index) {
                                    //       return ListTile(
                                    //         title: Text(
                                    //           controller.modelDetections[index],
                                    //           style: TextStyle(fontSize: 14),
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                )
                                // Center(
                                //       child: Text(
                                //         "Welcome to\n Cane2Scan",
                                //         style: TextStyle(
                                //           fontSize: 24,
                                //           color: Colors.white,
                                //           fontWeight: FontWeight.bold,
                                //         ),
                                //       ),
                                //     )
                                : Container(),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                //button code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() {
                      return ElevatedButton(
                        onPressed: () => controller.pickImage(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              controller.isImageSelected.value
                                  ? Colors
                                      .red // Change color to red when image is selected
                                  : Colors.blue, // Default color
                          minimumSize: Size(buttonWidth, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Select Image",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                    Obx(() {
                      return ElevatedButton(
                        onPressed:
                            controller.isImageSelected.value
                                ? () => controller.sendFileToServer()
                                : null, // Disable button if no image is selected
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              controller.isImageSent.value
                                  ? Colors
                                      .blue // Grey color when image is sent
                                  : Colors.green, // Default color
                          minimumSize: Size(buttonWidth, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Send Image to Server",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // Right-side Drawer
      endDrawer: Drawer(
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
                _showIpDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.connect_without_contact, color: Colors.black),
              title: Text(
                "Show IP Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                controller.showIp();
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.black),
              title: Text(
                "Control Panel",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showIpDialog(BuildContext context) {
    TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50, // Minimum height to ensure proper display
              maxHeight: 50, // Maximum height to prevent overflow
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjusts to fit the content
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: TextField(
                    controller: ipController,
                    decoration: InputDecoration(hintText: "Enter IP Address"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop(); // Close dialog from root navigator
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                String ip = ipController.text.trim();
                if (ip.isEmpty ||
                    !RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(ip)) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: "Invalid IP",
                    text: "Please enter a valid IP address.",
                  );
                } else {
                  controller.setServerIp(ip);

                  // Close the dialog first
                  Navigator.of(context, rootNavigator: true).pop();

                  // Wait for the dialog to close before showing the success alert
                  await Future.delayed(Duration(milliseconds: 300));

                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    title: "IP Saved",
                    text: "Your IP address is: $ip",
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Close on tap
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(imageBytes),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
//
// import '../../../widgets/animationDots.dart';
// import '../controllers/home_controller.dart';
//
// class HomeView extends GetView<HomeController> {
//   final HomeController controller = Get.put(HomeController());
//
//   HomeView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double buttonWidth = screenWidth / 2.9;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Cane2Scan",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Roboto',
//           ),
//         ),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         actions: [
//           Builder(
//             builder: (context) {
//               return IconButton(
//                 icon: Icon(Icons.menu, color: Colors.white),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Column(
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height / 2.3,
//                       child: Obx(
//                         () =>
//                             controller.selectedFile.value == null
//                                 ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Image.asset(
//                                     'assets/images/logo.png',
//                                     width:
//                                         MediaQuery.of(context).size.width / 1.2,
//                                     height:
//                                         MediaQuery.of(context).size.height /
//                                         2.4,
//                                     fit: BoxFit.fill,
//                                   ),
//                                 )
//                                 : controller.isUploading.value
//                                 ? CircularProgressIndicator()
//                                 : controller.resultImage.value != null
//                                 ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Obx(() {
//                                     return controller.resultImage.value != null
//                                         ? Image.file(
//                                           controller.resultImage.value!,
//                                           width:
//                                               MediaQuery.of(
//                                                 context,
//                                               ).size.width /
//                                               1.2,
//                                           height:
//                                               MediaQuery.of(
//                                                 context,
//                                               ).size.height /
//                                               2.4,
//                                           fit: BoxFit.fill,
//                                         )
//                                         : Text('No image detected');
//                                   }),
//                                 )
//                                 : Container(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height / 3.5,
//                     child: Obx(
//                       () =>
//                           controller.selectedFile.value == null
//                               ? Center(
//                                 child: Text(
//                                   "Welcome to Cane2Scan\n Please select image for process",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               )
//                               : controller.isUploading.value
//                               ? Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "Please Wait\n your image is being processed",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                   AnimatedDots(),
//                                 ],
//                               )
//                               : controller.resultImage.value != null
//                               ? Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Obx(() {
//                                     return Text("Status: ${controller.status}");
//                                   }),
//                                   Obx(() {
//                                     return Text(
//                                       "Confidence: ${controller.confidence}",
//                                     );
//                                   }),
//                                   Obx(() {
//                                     return Text(
//                                       "Confidence: ${controller.wld_count}",
//                                     );
//                                   }),
//                                   Obx(() {
//                                     return Text(
//                                       "Confidence: ${controller.processing_time}",
//                                     );
//                                   }),
//                                   Obx(() {
//                                     return ListView.builder(
//                                       itemCount:
//                                           controller.model_detections.length,
//                                       itemBuilder: (context, index) {
//                                         return ListTile(
//                                           title: Text(
//                                             controller.model_detections[index],
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   }),
//                                 ],
//                               )
//                               : Container(),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => controller.pickImage(),
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.blue,
//                         minimumSize: Size(buttonWidth, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         "Select Image",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         controller.sendFileToServer();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.blue,
//                         minimumSize: Size(buttonWidth, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         "Send Image to Server",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // Right-side Drawer
//       endDrawer: Drawer(
//         backgroundColor: Colors.white, // Set the drawer background to white
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(
//                     "assets/images/logo.png",
//                   ), // Replace with your asset
//                   fit: BoxFit.cover,
//                 ),
//                 color: Colors.blueAccent, // Optional: Header background color
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [],
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.connect_without_contact, color: Colors.black),
//               title: Text(
//                 "Change IP Address",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 _showIpDialog(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.connect_without_contact, color: Colors.black),
//               title: Text(
//                 "Show IP Address",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.admin_panel_settings, color: Colors.black),
//               title: Text(
//                 "Control Panel",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Function to show IP dialog
//   void _showIpDialog(BuildContext context) {
//     TextEditingController ipController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: TextField(
//                 controller: ipController,
//                 decoration: InputDecoration(hintText: "Enter IP Address"),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(
//                   context,
//                   rootNavigator: true,
//                 ).pop(); // Close dialog from root navigator
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () async {
//                 String ip = ipController.text.trim();
//                 if (ip.isEmpty ||
//                     !RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(ip)) {
//                   QuickAlert.show(
//                     context: context,
//                     type: QuickAlertType.error,
//                     title: "Invalid IP",
//                     text: "Please enter a valid IP address.",
//                   );
//                 } else {
//                   controller.setServerIp(ip);
//
//                   // Close the dialog first
//                   Navigator.of(context, rootNavigator: true).pop();
//
//                   // Wait for the dialog to close before showing the success alert
//                   await Future.delayed(Duration(milliseconds: 300));
//
//                   QuickAlert.show(
//                     context: context,
//                     type: QuickAlertType.success,
//                     title: "IP Saved",
//                     text: "Your IP address is: $ip",
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
