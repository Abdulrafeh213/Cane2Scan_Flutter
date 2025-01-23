import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/quickalert.dart';

class HomeController extends GetxController {
  var imageList = List.generate(10, (index) => "Image $index").obs;
  var currentImageIndex = 0.obs;
  var selectedFile = Rx<File?>(null);
  var resultImage = Rx<File?>(null);
  var isUploading = false.obs;
  var serverIp = '192.168.241.214'.obs;
  String originalImageBase64 = '';
  String detectionImageBase64 = '';

  // Additional data from server
  var status = ''.obs;
  var confidence = ''.obs;
  var message = ''.obs;
  var wldCount = 0.obs;
  var processingTime = ''.obs;
  var dateTime = ''.obs;
  var modelDetections = <String>[].obs;
  var collageImage = ''.obs;
  var croppedImages = <String>[].obs;

  var isImageSelected = false.obs;
  var isImageSent = false.obs;

  @override
  void onInit() {
    super.onInit();

    animateDots();
    // fetchDetections();
  }

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

  // Method to show the current IP address
  void showIp() {
    if (serverIp.value.isEmpty) {
      if (Get.context != null) {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.warning,
          title: "No Server IP",
          text: "No IP address has been set yet.",
        );
      }
    } else {
      if (Get.context != null) {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.info,
          title: "Current Server IP",
          text: "The current server IP is: ${serverIp.value}",
        );
      }
    }
  }

  // Future<void> pickImage() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //   );
  //
  //   if (result == null) return;
  //
  //   final filePath = result.files.single.path!;
  //   final file = File(filePath);
  //
  //   try {
  //     final compressedFile = await _compressAndResizeImage(file);
  //     selectedFile.value = compressedFile;
  //     isImageSelected.value = true;
  //   } catch (error) {
  //     QuickAlert.show(
  //       context: Get.context!,
  //       type: QuickAlertType.error,
  //       title: "Error",
  //       text: "Failed to compress or resize image: $error",
  //     );
  //   }
  // }
  //
  // FutureOr<File> _compressAndResizeImage(File imageFile) async {
  //   try {
  //     final picture = await decodeImageFromList(await imageFile.readAsBytes());
  //     final int? maxWidth = picture.width > picture.height ? 400 : null;
  //     final int? maxHeight = picture.width < picture.height ? 300 : null;
  //
  //     final int calculatedMaxWidth = maxWidth ?? 400;
  //     final int calculatedMaxHeight = maxHeight ?? 300;
  //
  //     final compressData = await FlutterImageCompress.compressWithList(
  //       await imageFile.readAsBytes(),
  //       minWidth: calculatedMaxWidth,
  //       minHeight: calculatedMaxHeight,
  //       quality: 80,
  //     );
  //
  //     final compressedFile = File('${imageFile.path}_compressed.jpg');
  //     await compressedFile.writeAsBytes(compressData);
  //     return compressedFile; // Return the compressed file
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Compression error: $e');
  //     }
  //     return imageFile;
  //   }
  // }
  //
  // // Upload file to server
  // Future<void> sendFileToServer() async {
  //   if (selectedFile.value == null) {
  //     QuickAlert.show(
  //       context: Get.context!,
  //       type: QuickAlertType.error,
  //       title: "Error",
  //       text: "No image selected to upload.",
  //     );
  //     return;
  //   }
  //   if (isImageSelected.value) {
  //     isImageSent.value = true;
  //     isImageSelected.value = false;
  //   }
  //
  //   if (serverIp.value.isEmpty) {
  //     QuickAlert.show(
  //       context: Get.context!,
  //       type: QuickAlertType.error,
  //       title: "Error",
  //       text: "Please set the server IP address.",
  //     );
  //     return;
  //   }
  //
  //   var endpoint = "http://${serverIp.value}:5000/detect";
  //
  //   isUploading.value = true;
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(endpoint));
  //
  //     var mimeType = lookupMimeType(selectedFile.value!.path);
  //     request.files.add(
  //       http.MultipartFile(
  //         'file',
  //         selectedFile.value!.openRead(),
  //         selectedFile.value!.lengthSync(),
  //         filename: selectedFile.value!.path.split('/').last,
  //         contentType: mimeType != null ? MediaType.parse(mimeType) : null,
  //       ),
  //     );
  //
  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       var responseData = await response.stream.bytesToString();
  //       var jsonResponse = jsonDecode(responseData);
  //
  //       // Handle the image data
  //       if (jsonResponse.containsKey('collage_image')) {
  //         String base64Image = jsonResponse['collage_image'];
  //         Uint8List bytes = base64Decode(base64Image);
  //
  //         // Saving the received image as a file
  //         resultImage.value = File(
  //           '${Directory.systemTemp.path}/image_from_server.png',
  //         )..writeAsBytesSync(bytes);
  //       } else {
  //         QuickAlert.show(
  //           context: Get.context!,
  //           type: QuickAlertType.error,
  //           title: "Error",
  //           text: "No image data returned from server.",
  //         );
  //       }
  //
  //       if (jsonResponse.containsKey('status')) {
  //         status.value = jsonResponse['status'];
  //
  //         // Show QuickAlert based on the 'status' value
  //         if (status.value == 'WLD Detected') {
  //           QuickAlert.show(
  //             context: Get.context!,
  //             type: QuickAlertType.success,
  //             title: "Detection Success",
  //             text: "White Leaf Disease (WLD) detected.",
  //           );
  //         } else if (status.value == 'No WLD Found') {
  //           QuickAlert.show(
  //             context: Get.context!,
  //             type: QuickAlertType.info,
  //             title: "No Disease Detected",
  //             text: "No disease found in the image.",
  //           );
  //         }
  //       }
  //
  //       if (jsonResponse.containsKey('message')) {
  //         message.value = jsonResponse['message'];
  //       }
  //       if (jsonResponse.containsKey('confidence')) {
  //         confidence.value = jsonResponse['confidence'];
  //       }
  //
  //       if (jsonResponse.containsKey('wld_count')) {
  //         wldCount.value = jsonResponse['wld_count'];
  //       }
  //
  //       if (jsonResponse.containsKey('processing_time')) {
  //         processingTime.value = jsonResponse['processing_time'];
  //       }
  //
  //       if (jsonResponse.containsKey('model_detections')) {
  //         var detections = jsonResponse['model_detections'];
  //         // Ensure detections is a map
  //         if (detections is Map) {
  //           modelDetections.clear();
  //           detections.forEach((key, value) {
  //             if (value is Map &&
  //                 value.containsKey('confidence') &&
  //                 value.containsKey('count')) {
  //               double confidence = value['confidence'] ?? 0.0;
  //               int count = value['count'] ?? 0;
  //               // Convert confidence to percentage
  //               String confidencePercentage = (confidence * 100)
  //                   .toStringAsFixed(2);
  //               modelDetections.add(
  //                 '$key: Confidence $confidencePercentage%, Detected: $count',
  //               );
  //             }
  //           });
  //         }
  //       }
  //
  //       if (jsonResponse.containsKey('cropped_images')) {
  //         var images = jsonResponse['cropped_images'];
  //         if (images is List) {
  //           // If it's a list of Base64 strings
  //           croppedImages.value = List<String>.from(images);
  //         } else if (images is String) {
  //           // If it's a single Base64 string
  //           croppedImages.value = [images];
  //         }
  //       }
  //     } else {
  //       throw Exception("Invalid server response: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     QuickAlert.show(
  //       context: Get.context!,
  //       type: QuickAlertType.error,
  //       title: "Error",
  //       text: "Failed to connect to /detect: $e",
  //     );
  //   } finally {
  //     isUploading.value = false;
  //   }
  // }
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;

    final filePath = result.files.single.path!;
    final file = File(filePath);

    // Directly assign the file without resizing or compressing
    selectedFile.value = file;
    isImageSelected.value = true;
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
    if (isImageSelected.value) {
      isImageSent.value = true;
      isImageSelected.value = false;
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
        if (jsonResponse.containsKey('collage_image')) {
          String base64Image = jsonResponse['collage_image'];
          Uint8List bytes = base64Decode(base64Image);

          // Saving the received image as a file
          resultImage.value = File(
            '${Directory.systemTemp.path}/image_from_server.png',
          )..writeAsBytesSync(bytes);
        } else {
          QuickAlert.show(
            context: Get.context!,
            type: QuickAlertType.error,
            title: "Error",
            text: "No image data returned from server.",
          );
        }

        if (jsonResponse.containsKey('status')) {
          status.value = jsonResponse['status'];

          // Show QuickAlert based on the 'status' value
          if (status.value == 'WLD Detected') {
            QuickAlert.show(
              context: Get.context!,
              type: QuickAlertType.success,
              title: "Detection Success",
              text: "White Leaf Disease (WLD) detected.",
            );
          } else if (status.value == 'No WLD Found') {
            QuickAlert.show(
              context: Get.context!,
              type: QuickAlertType.info,
              title: "No Disease Detected",
              text: "No disease found in the image.",
            );
          }
        }

        if (jsonResponse.containsKey('message')) {
          message.value = jsonResponse['message'];
        }
        if (jsonResponse.containsKey('confidence')) {
          confidence.value = jsonResponse['confidence'];
        }

        if (jsonResponse.containsKey('wld_count')) {
          wldCount.value = jsonResponse['wld_count'];
        }

        if (jsonResponse.containsKey('processing_time')) {
          processingTime.value = jsonResponse['processing_time'];
        }

        if (jsonResponse.containsKey('model_detections')) {
          var detections = jsonResponse['model_detections'];
          // Ensure detections is a map
          if (detections is Map) {
            modelDetections.clear();
            detections.forEach((key, value) {
              if (value is Map &&
                  value.containsKey('confidence') &&
                  value.containsKey('count')) {
                double confidence = value['confidence'] ?? 0.0;
                int count = value['count'] ?? 0;
                // Convert confidence to percentage
                String confidencePercentage = (confidence * 100)
                    .toStringAsFixed(2);
                modelDetections.add(
                  '$key: Confidence $confidencePercentage%, Detected: $count',
                );
              }
            });
          }
        }

        if (jsonResponse.containsKey('cropped_images')) {
          var images = jsonResponse['cropped_images'];
          if (images is List) {
            // If it's a list of Base64 strings
            croppedImages.value = List<String>.from(images);
          } else if (images is String) {
            // If it's a single Base64 string
            croppedImages.value = [images];
          }
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

  var dotCount = 0.obs;

  // Method to animate dots
  void animateDots() {
    Future.delayed(Duration(seconds: 3), () {
      dotCount.value = (dotCount.value + 1) % 4;
      animateDots();
    });
  }

  void updateCurrentImage(int index) {
    currentImageIndex.value = index;
  }
}
