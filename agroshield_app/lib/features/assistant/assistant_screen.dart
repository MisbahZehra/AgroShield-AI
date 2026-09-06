import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class _Message {
  final bool fromUser;
  final String text;
  const _Message(this.fromUser, this.text);
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _messages = <_Message>[];
  bool _busy = false;
  bool _listening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _busy) return;
    setState(() {
      _messages.add(_Message(true, text));
      _busy = true;
    });
    _controller.clear();
    final lastScan = ref.read(lastScanProvider);
    final lastClass = lastScan?.prediction.className;

    // Build conversation history from prior messages
    final history = _messages
        .map((m) => {
              'role': m.fromUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    // Build scan context from the latest scan result
    String? scanContext;
    if (lastScan != null) {
      final p = lastScan.prediction;
      scanContext =
          'Crop: ${p.crop}, Disease: ${p.className}, '
          'Confidence: ${(p.confidence * 100).toStringAsFixed(1)}%, '
          'Severity: ${lastScan.severity.severityLabel}';
    }

    final answer = await ref
        .read(assistantRepositoryProvider)
        .answer(text,
            lastClassName: lastClass,
            conversationHistory: history,
            scanContext: scanContext);
    if (mounted) {
      setState(() {
        _messages.add(_Message(false, answer));
        _busy = false;
      });
    }
  }

  Future<void> _toggleMic() async {
    final stt = ref.read(sttServiceProvider);

    // Already listening → stop and send accumulated text
    if (_listening) {
      await stt.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }

    // Start continuous listening
    if (!stt.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Speech recognition not available on this device')),
        );
      }
      return;
    }
    setState(() => _listening = true);
    await stt.startListening(
      onFinished: (text) {
        if (text.trim().isNotEmpty) {
          _controller.text = text;
          _send(text);
        }
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.assistantTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AgroCard(
                  color: AppColors.primaryLight,
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l.assistantHint,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryDark)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final q in [l.q1, l.q2, l.q3])
                      ActionChip(
                        label: Text(q, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _send(q),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._messages.map((m) => Align(
                      alignment: m.fromUser
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: m.fromUser
                              ? AppColors.primary
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: m.fromUser
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l.assistantDisclaimer,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          InputDecoration(hintText: l.askAgroShield),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _toggleMic,
                    tooltip: 'Voice input',
                    icon: Icon(
                      _listening ? Icons.stop : Icons.mic,
                      color: _listening
                          ? Colors.white
                          : AppColors.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _listening
                          ? AppColors.danger
                          : AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(_controller.text),
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
