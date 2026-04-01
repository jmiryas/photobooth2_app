// lib/domain/models/photo_model.dart
import 'dart:io';

class PhotoModel {
  final String id;
  final String filePath;
  final DateTime capturedAt;
  final int sequenceNumber; // 1, 2, 3, 4 untuk urutan foto

  PhotoModel({
    required this.id,
    required this.filePath,
    required this.capturedAt,
    required this.sequenceNumber,
  });

  PhotoModel copyWith({String? filePath, DateTime? capturedAt}) {
    return PhotoModel(
      id: id,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt ?? this.capturedAt,
      sequenceNumber: sequenceNumber,
    );
  }

  bool get isValid => filePath.isNotEmpty && File(filePath).existsSync();
}

// Helper untuk generate ID unik
String generatePhotoId() {
  return 'PH-${DateTime.now().millisecondsSinceEpoch}';
}
