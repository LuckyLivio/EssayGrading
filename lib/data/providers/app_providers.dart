import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});
