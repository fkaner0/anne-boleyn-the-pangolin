import 'package:flutter/material.dart';

class CodeOfConductDialog extends StatelessWidget {
  const CodeOfConductDialog({super.key});

  static const List<({String title, String body})> _rules = [
    (
      title: 'Protect privacy',
      body:
          'Avoid posting any personal information. Any posts that include an '
          'email address, phone number, address or other personal information '
          'will be removed.',
    ),
    (
      title: 'Stay on topic',
      body:
          'We welcome debate and discussion, but please keep comments '
          'relevant to the original post, and don\'t repeat the same message '
          'across multiple unrelated posts. Off-topic posts or comments are '
          'likely to be removed.',
    ),
    (
      title: 'Be respectful',
      body:
          'Please avoid posting any hateful, defamatory, obscene, '
          'discriminatory or harassing comments, images or videos, or anything '
          'that could be deemed offensive to others. Such comments and posts '
          'will be removed, and will most likely result in you being banned or '
          'blocked.',
    ),
    (
      title: 'Don\'t advertise or self-promote',
      body:
          'Avoid making posts or comments that serve as advertisements for '
          'yourself or others. We\'ll remove any links, images, messages, and '
          'so on that advertise or promote the goods or services of '
          'individuals, businesses or causes and such postings will most '
          'likely result in you being banned or blocked.',
    ),
    (
      title: 'Don\'t infringe intellectual property',
      body:
          'Avoid posting anything that isn\'t your original creative content '
          'or that you don\'t have a lawful right to post. Infringed branded '
          'logos, graphics, copyrighted text, images or videos that come to '
          'our attention will be removed, and you risk being banned or '
          'blocked.',
    ),
  ];

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const CodeOfConductDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.primary,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Code of Conduct',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (index, rule) in _rules.indexed) ...[
                          if (index > 0) const SizedBox(height: 16),
                          Text(
                            '${index + 1}. ${rule.title}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rule.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        side: BorderSide(color: colorScheme.onPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
