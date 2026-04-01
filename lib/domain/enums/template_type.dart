// lib/domain/enums/template_type.dart
import '../../core/constants/app_constants.dart';

enum TemplateType {
  solo(
    id: AppConstants.templateSolo,
    label: 'Solo',
    description: '1 Foto Besar',
    photoCount: 1,
    layout: PhotoLayout.single,
  ),
  duo(
    id: AppConstants.templateDuo,
    label: 'Duo',
    description: '2 Foto Vertikal',
    photoCount: 2,
    layout: PhotoLayout.vertical,
  ),
  trio(
    id: AppConstants.templateTrio,
    label: 'Trio',
    description: '3 Foto Kotak',
    photoCount: 3,
    layout: PhotoLayout.vertical,
  ),
  quadro(
    id: AppConstants.templateQuadro,
    label: 'Quadro',
    description: '4 Foto Grid',
    photoCount: 4,
    layout: PhotoLayout.grid2x2,
  );

  final String id;
  final String label;
  final String description;
  final int photoCount;
  final PhotoLayout layout;

  const TemplateType({
    required this.id,
    required this.label,
    required this.description,
    required this.photoCount,
    required this.layout,
  });

  static TemplateType fromId(String id) {
    return values.firstWhere(
      (e) => e.id == id,
      orElse: () => TemplateType.solo,
    );
  }
}

enum PhotoLayout {
  single, // 1 foto besar
  vertical, // stack vertical
  grid2x2, // 2x2 grid
}
