import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/i18n/app_strings.dart';

/// Confirmation dialog for the dangerous "whole-book word order reset"
/// action. Enforces a 10-second cooling-off period before the Confirm button
/// can be tapped, matching the design doc's spec for this irreversible action.
class BookResetDialog extends StatefulWidget {
  const BookResetDialog({
    super.key,
    required this.lang,
    required this.bookId,
  });

  final String lang;
  final int bookId;

  static Future<bool?> show(
    BuildContext context, {
    required String lang,
    required int bookId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BookResetDialog(lang: lang, bookId: bookId),
    );
  }

  @override
  State<BookResetDialog> createState() => _BookResetDialogState();
}

class _BookResetDialogState extends State<BookResetDialog> {
  static const _cooldownSeconds = 10;
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _cooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
      });
      if (_remaining <= 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.lang;
    final canConfirm = _remaining <= 0;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded,
          size: 36, color: theme.colorScheme.error),
      title: Text(
        AppStrings.get('reset_book_order_title', lang),
        textAlign: TextAlign.center,
      ),
      content: Text(
        AppStrings.get('reset_book_order_warning', lang),
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppStrings.get('cancel', lang)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            disabledBackgroundColor: theme.colorScheme.error.withValues(
              alpha: 0.3,
            ),
          ),
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(
            canConfirm
                ? AppStrings.get('reset_book_order_confirm', lang)
                : AppStrings.get(
                    'reset_book_order_cooldown',
                    lang,
                    params: {'seconds': _remaining.toString()},
                  ),
          ),
        ),
      ],
    );
  }
}
