import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchResults() async {
    final snapshot = await _firestore.collection('detections').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
