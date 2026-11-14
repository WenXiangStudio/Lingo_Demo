import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../models/narration_models.dart';
import '../providers/narration_provider.dart';

class NarrationProgressScreen extends ConsumerWidget {
  const NarrationProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final progress = ref.watch(narrationProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('narration_progress', lang))),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(AppStrings.get('narration_load_failed', lang))),
        data: (points) => points.isEmpty
            ? Center(child: Text(AppStrings.get('narration_no_progress', lang)))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _TrendSummary(points: points, lang: lang),
                  const SizedBox(height: 14),
                  _MiniTrendCard(
                    title: AppStrings.get('narration_error_trend', lang),
                    values: points
                        .map((point) => point.totalErrors.toDouble())
                        .toList(),
                    lowerIsBetter: true,
                  ),
                  const SizedBox(height: 10),
                  _MiniTrendCard(
                    title: AppStrings.get('narration_substitute_trend', lang),
                    values: points
                        .map((point) => point.chineseSubstituteCount.toDouble())
                        .toList(),
                    lowerIsBetter: true,
                  ),
                  const SizedBox(height: 10),
                  _MiniTrendCard(
                    title: AppStrings.get('narration_length_trend', lang),
                    values: points
                        .map((point) => point.englishWordCount.toDouble())
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  _MiniTrendCard(
                    title: AppStrings.get('narration_complexity_trend', lang),
                    values: points.map((point) => point.complexity).toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.get('narration_progress_note', lang),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TrendSummary extends StatelessWidget {
  const _TrendSummary({required this.points, required this.lang});

  final List<NarrationProgressPoint> points;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final latest = points.last;
    final previous = points.length > 1 ? points[points.length - 2] : null;
    final realSuccess = points.fold<int>(
      0,
      (sum, item) => sum + item.realUseSuccessCount,
    );
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('narration_latest_summary', lang),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    '${AppStrings.get('narration_errors', lang)} ${latest.totalErrors}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppStrings.get('narration_words', lang)} ${latest.englishWordCount}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppStrings.get('narration_real_use', lang)} $realSuccess',
                  ),
                ),
              ],
            ),
            if (previous != null) ...[
              const SizedBox(height: 10),
              Text(
                AppStrings.get(
                  'narration_vs_last',
                  lang,
                  params: {
                    'errors': _signed(
                      latest.totalErrors - previous.totalErrors,
                    ),
                    'words': _signed(
                      latest.englishWordCount - previous.englishWordCount,
                    ),
                    'substitutes': _signed(
                      latest.chineseSubstituteCount -
                          previous.chineseSubstituteCount,
                    ),
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';
}

class _MiniTrendCard extends StatelessWidget {
  const _MiniTrendCard({
    required this.title,
    required this.values,
    this.lowerIsBetter = false,
  });

  final String title;
  final List<double> values;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    final delta = values.length < 2 ? 0 : values.last - values.first;
    final positive = lowerIsBetter ? delta <= 0 : delta >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(
                  delta == 0
                      ? Icons.trending_flat
                      : positive
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: positive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              width: double.infinity,
              child: CustomPaint(painter: _TrendPainter(values)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4D6BFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = const Color(0xFF4D6BFF);
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(1, maxValue - minValue);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i * size.width / (values.length - 1);
      final y =
          size.height -
          ((values[i] - minValue) / span * size.height * 0.8) -
          size.height * 0.1;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dot);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
