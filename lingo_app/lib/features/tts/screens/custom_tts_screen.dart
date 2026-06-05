import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/services/tts_providers.dart';
import '../../../data/providers.dart';

/// Free-form text TTS reader per design "核心额外功能：文本转 TTS 语音 →
/// 用户还可以自己上传文本". Uses the active TTS engine (Supertonic / Qwen /
/// Doubao / SAPI) to read whatever the user types or pastes.
class CustomTtsScreen extends ConsumerStatefulWidget {
  const CustomTtsScreen({super.key});

  @override
  ConsumerState<CustomTtsScreen> createState() => _CustomTtsScreenState();
}

class _CustomTtsScreenState extends ConsumerState<CustomTtsScreen> {
  final _controller = TextEditingController();
  bool _isSpeaking = false;
  String? _lastError;
  String? _lastStatus;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty || _isSpeaking) return;
    setState(() {
      _isSpeaking = true;
      _lastError = null;
      _lastStatus = null;
    });
    try {
      final tts = ref.read(ttsServiceProvider);
      final result = await tts.speakCustomText(raw);
      final summary = result.message == null
          ? '${result.provider}:${result.source}'
          : '${result.provider}:${result.source} (${result.message})';
      if (!result.played && result.source != 'blocked') {
        throw Exception(result.message ?? result.source);
      }
      if (mounted) setState(() => _lastStatus = summary);
    } catch (e) {
      if (mounted) setState(() => _lastError = e.toString());
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _lastError = null;
      _lastStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('custom_tts_title', lang))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.get('custom_tts_intro', lang),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AppStrings.get('custom_tts_hint', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if (_lastError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_lastStatus != null) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.get(
                  'custom_tts_last_status',
                  lang,
                  params: {'status': _lastStatus!},
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasText && !_isSpeaking ? _clear : null,
                    icon: const Icon(Icons.clear),
                    label: Text(AppStrings.get('custom_tts_clear', lang)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasText && !_isSpeaking ? _speak : null,
                    icon: _isSpeaking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up),
                    label: Text(
                      _isSpeaking
                          ? AppStrings.get('custom_tts_speaking', lang)
                          : AppStrings.get('custom_tts_speak', lang),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
