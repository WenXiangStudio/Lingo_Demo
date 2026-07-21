import 'dart:convert';
import 'dart:io';

import '../../../../core/data_dir.dart';
import '../models/diagnosis_lab_record.dart';

class DiagnosisLabRecordStore {
  static const _relativePath =
      'diagnosis_lab/present_tense_diagnosis_records.json';

  Future<DiagnosisLabRecord> saveSubmission(DiagnosisLabRecord record) async {
    final records = await _readRecords();
    records.insert(0, record);
    await _writeRecords(records);
    return record;
  }

  Future<DiagnosisLabRecord> saveRating({
    required String recordId,
    required DiagnosisLabRating rating,
  }) async {
    final records = await _readRecords();
    final index = records.indexWhere((record) => record.id == recordId);
    if (index == -1) {
      throw StateError('Diagnosis lab record not found: $recordId');
    }
    final updated = records[index].copyWith(manualRating: rating);
    records[index] = updated;
    await _writeRecords(records);
    return updated;
  }

  Future<List<DiagnosisLabRecord>> loadRecords({int limit = 20}) async {
    final records = await _readRecords();
    return records.take(limit).toList(growable: false);
  }

  Future<List<DiagnosisLabRecord>> _readRecords() async {
    final file = await _recordsFile();
    if (!await file.exists()) return <DiagnosisLabRecord>[];
    final text = await file.readAsString();
    if (text.trim().isEmpty) return <DiagnosisLabRecord>[];
    final decoded = jsonDecode(text);
    if (decoded is! List) return <DiagnosisLabRecord>[];
    final records = decoded
        .whereType<Map>()
        .map((item) => DiagnosisLabRecord.fromJson(item.cast()))
        .where((record) => record.id.isNotEmpty)
        .toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<String> recordsPath() async => (await _recordsFile()).path;

  Future<void> _writeRecords(List<DiagnosisLabRecord> records) async {
    final file = await _recordsFile();
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      '${encoder.convert(records.map((record) => record.toJson()).toList())}\n',
    );
  }

  Future<File> _recordsFile() async {
    final root = await getLingoDataDir();
    return File('${root.path}${Platform.pathSeparator}$_relativePath');
  }
}
