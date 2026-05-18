import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const feedbackEmail = 'feedback@calcstudioapp.com';

Future<void> showFeedbackDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const FeedbackDialog(),
  );
}

Future<void> showInstallInfoDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const InstallInfoDialog(),
  );
}

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _contactController = TextEditingController();
  final _messageController = TextEditingController();
  String _kind = 'Suggestion';

  @override
  void dispose() {
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: const Icon(Icons.feedback_rounded),
      title: Text(
        'Send feedback',
        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w800),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us what happened, what you expected, or what calculator you want next. Your draft is copied so you can send it by email.',
              style: GoogleFonts.ibmPlexSans(
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Feedback type'),
              items: const [
                DropdownMenuItem(
                  value: 'Suggestion',
                  child: Text('Suggestion'),
                ),
                DropdownMenuItem(
                  value: 'Incorrect result',
                  child: Text('Incorrect result'),
                ),
                DropdownMenuItem(
                  value: 'Bug report',
                  child: Text('Bug report'),
                ),
                DropdownMenuItem(
                  value: 'Missing calculator',
                  child: Text('Missing calculator'),
                ),
              ],
              onChanged: (value) => setState(() => _kind = value ?? _kind),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email or name (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              minLines: 4,
              maxLines: 7,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'Include the calculator name and expected result.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedbackEmail,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _messageController.text.trim().isEmpty
              ? null
              : () => _copyFeedback(context),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy draft'),
        ),
      ],
    );
  }

  Future<void> _copyFeedback(BuildContext context) async {
    var route = '/';
    try {
      route = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final contact = _contactController.text.trim();
    final message = _messageController.text.trim();
    final draft = [
      'Calc Studio feedback',
      'Type: $_kind',
      if (contact.isNotEmpty) 'Contact: $contact',
      'Route: $route',
      '',
      message,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: draft));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feedback draft copied. Send it to $feedbackEmail.',
          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class InstallInfoDialog extends StatelessWidget {
  const InstallInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.install_mobile_rounded),
      title: Text(
        'Install & plugins',
        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w800),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _InfoBlock(
              icon: Icons.desktop_windows_rounded,
              title: 'Desktop install',
              body:
                  'In Chrome or Edge, use the install button in the address bar or browser menu to add Calc Studio as an app.',
            ),
            SizedBox(height: 14),
            _InfoBlock(
              icon: Icons.phone_android_rounded,
              title: 'Mobile install',
              body:
                  'On Android, use Install app or Add to Home screen. On iPhone or iPad, use Share, then Add to Home Screen.',
            ),
            SizedBox(height: 14),
            _InfoBlock(
              icon: Icons.extension_rounded,
              title: 'Plugins',
              body:
                  'No browser plugin is required. Calculations run on your device; only currency conversion needs a network request for exchange rates.',
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.ibmPlexSans(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
