import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/diagnosis/present_tense_diagnosis_client.dart';
import '../services/diagnosis_lab_record_store.dart';

final presentTenseDiagnosisClientProvider =
    Provider<PresentTenseDiagnosisClient>(
      (ref) => PresentTenseDiagnosisClient(),
    );

final diagnosisLabRecordStoreProvider = Provider<DiagnosisLabRecordStore>(
  (ref) => DiagnosisLabRecordStore(),
);
