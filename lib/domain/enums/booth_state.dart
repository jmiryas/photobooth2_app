// lib/domain/enums/booth_state.dart
enum BoothState { idle, selectTemplate, capture, preview, payment, done }

extension BoothStateExtension on BoothState {
  String get displayName {
    switch (this) {
      case BoothState.idle:
        return 'Idle';
      case BoothState.selectTemplate:
        return 'Pilih Template';
      case BoothState.capture:
        return 'Mengambil Foto';
      case BoothState.preview:
        return 'Preview';
      case BoothState.payment:
        return 'Pembayaran';
      case BoothState.done:
        return 'Selesai';
    }
  }
}
