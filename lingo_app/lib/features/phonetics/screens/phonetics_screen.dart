import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../data/providers.dart';
import '../data/british_phoneme_catalog.dart';
import '../models/phoneme_definition.dart';
import '../services/phoneme_audio_player.dart';

class PhoneticsScreen extends ConsumerStatefulWidget {
  const PhoneticsScreen({super.key, this.audioPlayer});

  final PhonemeAudioPlayer? audioPlayer;

  @override
  ConsumerState<PhoneticsScreen> createState() => _PhoneticsScreenState();
}

class _PhoneticsScreenState extends ConsumerState<PhoneticsScreen> {
  late final PhonemeAudioPlayer _audioPlayer;
  late final bool _ownsAudioPlayer;
  String? _activePhonemeId;
  int _playRequestId = 0;

  @override
  void initState() {
    super.initState();
    _ownsAudioPlayer = widget.audioPlayer == null;
    _audioPlayer = widget.audioPlayer ?? AssetPhonemeAudioPlayer();
  }

  @override
  void dispose() {
    _playRequestId++;
    if (_ownsAudioPlayer) {
      unawaited(_audioPlayer.dispose());
    } else {
      unawaited(_audioPlayer.stop());
    }
    super.dispose();
  }

  Future<void> _play(PhonemeDefinition phoneme) async {
    final requestId = ++_playRequestId;
    setState(() => _activePhonemeId = phoneme.id);

    try {
      await _audioPlayer.playAsset(phoneme.assetPath);
    } catch (_) {
      if (!mounted || requestId != _playRequestId) return;
      final lang = ref.read(languageProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get(
              'phonetics_play_failed',
              lang,
              params: {'symbol': phoneme.symbol},
            ),
          ),
        ),
      );
    } finally {
      if (mounted && requestId == _playRequestId) {
        setState(() => _activePhonemeId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('phonetics_title', lang))),
      body: CustomScrollView(
        slivers: [
          for (final group in PhonemeGroup.values) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  group == PhonemeGroup.monophthongs ? 18 : 24,
                  16,
                  10,
                ),
                child: Text(
                  AppStrings.get(group.labelKey, lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 136,
                  mainAxisExtent: 102,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final phoneme = phonemesFor(group)[index];
                  return _PhonemeTile(
                    phoneme: phoneme,
                    lang: lang,
                    active: _activePhonemeId == phoneme.id,
                    onTap: () => unawaited(_play(phoneme)),
                  );
                }, childCount: phonemesFor(group).length),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _PhonemeTile extends StatelessWidget {
  const _PhonemeTile({
    required this.phoneme,
    required this.lang,
    required this.active,
    required this.onTap,
  });

  final PhonemeDefinition phoneme;
  final String lang;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: AppStrings.get(
        'phonetics_play_label',
        lang,
        params: {'symbol': phoneme.symbol, 'example': phoneme.example},
      ),
      child: Card(
        key: ValueKey('phoneme-${phoneme.id}'),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: active ? colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 38,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '/${phoneme.symbol}/',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            phoneme.example,
                            maxLines: 1,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: foreground.withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Icon(
                  active ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                  key: ValueKey('phoneme-audio-${phoneme.id}'),
                  size: 17,
                  color: active
                      ? colorScheme.primary
                      : foreground.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
