class DiseaseModel {
  final String diseaseType;
  final double confidence;
  final String prediction;

  DiseaseModel({required this.diseaseType, required this.confidence, required this.prediction});

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      diseaseType: json['diseaseType'],
      confidence: json['confidence'],
      prediction: json['prediction'],
    );
  }
}
