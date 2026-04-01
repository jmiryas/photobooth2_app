// lib/presentation/providers/booth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/enums/booth_state.dart';
import '../../domain/enums/template_type.dart';
import '../../domain/models/session_model.dart';
import '../../domain/models/transaction_model.dart';

class BoothProvider extends ChangeNotifier {
  // State
  BoothState _currentState = BoothState.idle;
  TemplateType? _selectedTemplate;
  SessionModel? _currentSession;

  // Capture state
  final List<String> _capturedPhotos = [];
  int _currentPhotoIndex = 0;
  int _retakeUsed = 0;
  bool _isRetakeMode = false;

  // Payment state
  Timer? _paymentTimer;
  int _paymentTimeLeft = AppConstants.paymentTimeoutSeconds;

  // Done state
  Timer? _doneTimer;
  int _doneTimeLeft = AppConstants.doneScreenTimeoutSeconds;

  // Getters
  BoothState get currentState => _currentState;
  TemplateType? get selectedTemplate => _selectedTemplate;
  SessionModel? get currentSession => _currentSession;

  List<String> get capturedPhotos => List.unmodifiable(_capturedPhotos);
  int get currentPhotoIndex => _currentPhotoIndex;
  int get retakeUsed => _retakeUsed;
  int get retakeLeft => AppConstants.retakeQuota - _retakeUsed;
  bool get canRetake => retakeLeft > 0;
  bool get isRetakeMode => _isRetakeMode;

  int get totalPhotosNeeded => _selectedTemplate?.photoCount ?? 1;
  bool get isLastPhoto => _currentPhotoIndex >= totalPhotosNeeded - 1;

  int get paymentTimeLeft => _paymentTimeLeft;
  String get formattedPaymentTime {
    final minutes = _paymentTimeLeft ~/ 60;
    final seconds = _paymentTimeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get doneTimeLeft => _doneTimeLeft;
  String get formattedDoneTime {
    final minutes = _doneTimeLeft ~/ 60;
    final seconds = _doneTimeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get hasSelectedTemplate => _selectedTemplate != null;
  bool get isSessionComplete => _capturedPhotos.every((p) => p.isNotEmpty);

  // State Transitions

  void startSession() {
    _resetSession();
    _transitionTo(BoothState.selectTemplate);
  }

  void selectTemplate(TemplateType type) {
    _selectedTemplate = type;
    notifyListeners();
  }

  void confirmTemplate() {
    if (_selectedTemplate == null) return;

    // Initialize session
    _currentSession = SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      template: _selectedTemplate!,
      photoPaths: List.filled(_selectedTemplate!.photoCount, ''),
      createdAt: DateTime.now(),
    );

    _capturedPhotos.clear();
    _capturedPhotos.addAll(List.filled(_selectedTemplate!.photoCount, ''));
    _currentPhotoIndex = 0;
    _retakeUsed = 0;
    _isRetakeMode = false;

    _transitionTo(BoothState.capture);
  }

  void savePhoto(String filePath) {
    if (_currentPhotoIndex >= 0 &&
        _currentPhotoIndex < _capturedPhotos.length) {
      _capturedPhotos[_currentPhotoIndex] = filePath;

      // Update session model
      if (_currentSession != null) {
        final newPaths = List<String>.from(_capturedPhotos);
        _currentSession = _currentSession!.copyWith(photoPaths: newPaths);
      }

      notifyListeners();
    }
  }

  void nextPhoto() {
    if (_currentPhotoIndex < totalPhotosNeeded - 1) {
      _currentPhotoIndex++;
      notifyListeners();
    } else {
      finishCapture();
    }
  }

  void finishCapture() {
    _isRetakeMode = false;
    _currentPhotoIndex = 0;
    _transitionTo(BoothState.preview);
  }

  void selectPhotoForRetake(int index) {
    if (index < 0 || index >= _capturedPhotos.length) return;
    _currentPhotoIndex = index;
    notifyListeners();
  }

  void processRetake() {
    if (!canRetake) return;

    _retakeUsed++;
    _isRetakeMode = true;
    _transitionTo(BoothState.capture);
  }

  void confirmPhotos() {
    _transitionTo(BoothState.payment);
    _startPaymentTimer();
  }

  void _startPaymentTimer() {
    _paymentTimeLeft = AppConstants.paymentTimeoutSeconds;
    _paymentTimer?.cancel();

    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_paymentTimeLeft > 0) {
        _paymentTimeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        resetToIdle(); // Timeout, kembali ke idle
      }
    });
  }

  void paymentSuccess() {
    _paymentTimer?.cancel();

    // Create transaction
    final transaction = TransactionModel(
      orderNumber: TransactionModel.generateOrderNumber(),
      timestamp: DateTime.now(),
      items: [
        TransactionItem(
          name: 'Foto ${_selectedTemplate?.label} · 1 sesi',
          price: AppConstants.pricePerSession,
        ),
      ],
    );

    // Update session
    _currentSession = _currentSession?.copyWith(
      isPaid: true,
      completedAt: DateTime.now(),
    );

    _transitionTo(BoothState.done);
    _startDoneTimer();
  }

  void _startDoneTimer() {
    _doneTimeLeft = AppConstants.doneScreenTimeoutSeconds;
    _doneTimer?.cancel();

    _doneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_doneTimeLeft > 0) {
        _doneTimeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        resetToIdle();
      }
    });
  }

  void resetToIdle() {
    _paymentTimer?.cancel();
    _doneTimer?.cancel();
    _transitionTo(BoothState.idle);
    _resetSession();
  }

  void endSessionEarly() {
    _doneTimer?.cancel();
    resetToIdle();
  }

  // Private helpers

  void _transitionTo(BoothState newState) {
    debugPrint('State: $_currentState → $newState');
    _currentState = newState;
    notifyListeners();
  }

  void _resetSession() {
    _selectedTemplate = null;
    _currentSession = null;
    _capturedPhotos.clear();
    _currentPhotoIndex = 0;
    _retakeUsed = 0;
    _isRetakeMode = false;
    _paymentTimeLeft = AppConstants.paymentTimeoutSeconds;
    _doneTimeLeft = AppConstants.doneScreenTimeoutSeconds;
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    _doneTimer?.cancel();
    super.dispose();
  }
}
