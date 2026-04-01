// lib/domain/models/session_model.dart
import '../enums/template_type.dart';

class SessionModel {
  final String id;
  final TemplateType template;
  final List<String> photoPaths;
  final int retakeUsed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isPaid;
  final String? printerStatus;

  SessionModel({
    required this.id,
    required this.template,
    required this.photoPaths,
    this.retakeUsed = 0,
    required this.createdAt,
    this.completedAt,
    this.isPaid = false,
    this.printerStatus,
  });

  bool get canRetake => retakeUsed < 3;
  int get retakeLeft => 3 - retakeUsed;
  bool get isComplete => photoPaths.every((p) => p.isNotEmpty);

  List<String> get validPhotos =>
      photoPaths.where((p) => p.isNotEmpty).toList();

  SessionModel copyWith({
    List<String>? photoPaths,
    int? retakeUsed,
    DateTime? completedAt,
    bool? isPaid,
    String? printerStatus,
  }) {
    return SessionModel(
      id: id,
      template: template,
      photoPaths: photoPaths ?? this.photoPaths,
      retakeUsed: retakeUsed ?? this.retakeUsed,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      isPaid: isPaid ?? this.isPaid,
      printerStatus: printerStatus ?? this.printerStatus,
    );
  }
}
