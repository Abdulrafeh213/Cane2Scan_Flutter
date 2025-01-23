import 'package:get/get.dart';
import 'firebase_services.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService());
  }
}
