//working code
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

void main() {
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cane2Scan: WLD Detection System",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Set IP Address'),
              onTap: () {
                _showIpDialog(context);
              },
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height / 2.4,
                      child: Center(
                        child: Obx(
                          () =>
                              controller.selectedFile.value == null
                                  ? Image.asset(
                                    'assets/images/logo.png',
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height:
                                        MediaQuery.of(context).size.height /
                                        2.4,
                                    fit: BoxFit.fill,
                                  )
                                  : controller.isUploading.value
                                  ? CircularProgressIndicator()
                                  : controller.resultImage.value != null
                                  ? Row(
                                    children: [
                                      Image.file(
                                        controller.resultImage.value!,
                                        width:
                                            MediaQuery.of(context).size.width /
                                            1.2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                            2.4,
                                        fit: BoxFit.fill,
                                      ),
                                      Image.file(
                                        controller.selectedFile.value!,
                                        width:
                                            MediaQuery.of(context).size.width /
                                            1.2,
                                        height:
                                            MediaQuery.of(context).size.height /
                                            2.4,
                                        fit: BoxFit.fill,
                                      ),
                                    ],
                                  )
                                  : Container(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          width: MediaQuery.of(context).size.width / 2.2,
                          height: MediaQuery.of(context).size.height / 3.5,
                          child: Center(
                            child: Row(children: [Text("Result Data Here")]),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => controller.pickImage(),
                            icon: Icon(Icons.image),
                            label: Text('Pick Image'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => controller.sendFileToServer(),
                            icon: Icon(Icons.send),
                            label: Text('Send Image to Server'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: ListView.builder(
                          itemCount: controller.imageList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => controller.updateCurrentImage(index),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 70,
                                child: Center(
                                  child: Text(
                                    controller.imageList[index],
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show IP dialog
  void _showIpDialog(BuildContext context) {
    TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TextField(
                controller: ipController,
                decoration: InputDecoration(hintText: "Enter IP Address"),
                keyboardType: TextInputType.number,
              ),
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
}

class HomeController extends GetxController {
  var imageList = List.generate(10, (index) => "Image $index").obs;
  var currentImageIndex = 0.obs;
  var selectedFile = Rx<File?>(null);
  var resultImage = Rx<File?>(null);
  var isUploading = false.obs;
  var serverIp = ''.obs;
  String originalImageBase64 = ''; // For the original image
  String detectionImageBase64 = ''; // For the detection image

  // Method to set the server IP address
  void setServerIp(String ip) async {
    if (!RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$').hasMatch(ip)) {
      if (Get.context != null) {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.error,
          title: "Error",
          text: "Invalid IP address. Please enter a valid one.",
        );
      }
      return;
    }

    serverIp.value = ip;
    var testUrl = Uri.parse("http://$ip:5000/test");

    try {
      var response = await http.get(testUrl);
      if (response.statusCode == 200) {
        if (Get.context != null) {
          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.success,
            title: "Success",
            text: "Successfully connected to the server!",
          );
        }
      } else {
        throw Exception("Connection failed: ${response.statusCode}");
      }
    } catch (e) {
      serverIp.value = '';
      if (Get.context != null) {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.error,
          title: "Error",
          text: "Failed to connect to the server at $ip. Please try again.",
        );
      }
    }
  }

  // Pick image from file system
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      selectedFile.value = File(result.files.single.path!);
    } else {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: "Error",
        text: "No image selected.",
      );
    }
  }

  // Upload file to server
  Future<void> sendFileToServer() async {
    if (selectedFile.value == null) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: "Error",
        text: "No image selected to upload.",
      );
      return;
    }

    if (serverIp.value.isEmpty) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: "Error",
        text: "Please set the server IP address.",
      );
      return;
    }

    var endpoint = "http://${serverIp.value}:5000/detect";

    isUploading.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      var mimeType = lookupMimeType(selectedFile.value!.path);
      request.files.add(
        http.MultipartFile(
          'file',
          selectedFile.value!.openRead(),
          selectedFile.value!.lengthSync(),
          filename: selectedFile.value!.path.split('/').last,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        // Handle the image data
        if (jsonResponse.containsKey('image_base64')) {
          String base64Image = jsonResponse['image_base64'];
          Uint8List bytes = base64Decode(base64Image);

          // Saving the received image as a file
          resultImage.value = File(
            '${Directory.systemTemp.path}/image_from_server.png',
          )..writeAsBytesSync(bytes);

          // Optionally show intermediate progress to the user
          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.success,
            title: "Success",
            text: "Detection completed.",
          );
        } else {
          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.error,
            title: "Error",
            text: "No image data returned from server.",
          );
        }

        // Handle WLD detection and show alert if found
        if (jsonResponse.containsKey('detections')) {
          var detections = jsonResponse['detections'];
          bool swldDetected = false;

          // Check if WLD (White Leaf Disease) is detected
          for (var detection in detections) {
            if (detection.contains('WLD') ||
                detection.contains('white leaf disease')) {
              swldDetected = true;
              break;
            }
          }
        }

        // Handle additional data such as processing time
        if (jsonResponse.containsKey('processing_time')) {
          var processingTime = jsonResponse['processing_time'];
          // Show or log the processing time if needed
          print("Processing Time: $processingTime");
        }
      } else {
        throw Exception("Invalid server response: ${response.statusCode}");
      }
    } catch (e) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to connect to /detect: $e",
      );
    } finally {
      isUploading.value = false;
    }
  }

  void updateCurrentImage(int index) {
    currentImageIndex.value = index;
  }
}
