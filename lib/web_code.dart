import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Cane2ScanDashboard());
}

class Cane2ScanDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cane2Scan Dashboard',
      theme: ThemeData.dark(),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cane2Scan Dashboard"), centerTitle: true),
      body: Row(
        children: [
          // Side Navigation Bar
          NavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Metrics Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MetricCard(
                        title: "Total Images Processed",
                        value: controller.totalImages.toString(),
                      ),
                      MetricCard(
                        title: "Detected WLD Cases",
                        value: controller.wldCases.toString(),
                      ),
                      MetricCard(
                        title: "Average Confidence",
                        value: "${controller.confidence}%",
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Detection Results Table
                  Text(
                    "Detection Results",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else if (controller.results.isEmpty) {
                      return Text("No results found.");
                    } else {
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text("Image Name")),
                          DataColumn(label: Text("Detection")),
                          DataColumn(label: Text("Confidence")),
                          DataColumn(label: Text("Timestamp")),
                        ],
                        rows:
                            controller.results.map((result) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(result["image"])),
                                  DataCell(Text(result["detection"])),
                                  DataCell(Text("${result["confidence"]}%")),
                                  DataCell(Text(result["timestamp"])),
                                ],
                              );
                            }).toList(),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation Bar Widget
class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.white),
            title: Text("Dashboard", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: Colors.white),
            title: Text("Analytics", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.map, color: Colors.white),
            title: Text("Maps", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text("Settings", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Metric Card Widget
class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.white70)),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard Controller
class DashboardController extends GetxController {
  var totalImages = 0.obs;
  var wldCases = 0.obs;
  var confidence = 0.obs;
  var isLoading = false.obs;
  var results = <Map<String, dynamic>>[].obs;

  DashboardController() {
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    isLoading(true);

    // Replace with your API endpoint
    const url = "http://192.168.107.214:5000/detect";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        totalImages.value = data["total_images"];
        wldCases.value = data["wld_cases"];
        confidence.value = data["confidence"];
        results.value = List<Map<String, dynamic>>.from(data["results"]);
      } else {
        Get.snackbar("Error", "Failed to load data.");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
