import 'package:flutter/material.dart';

class CodeOfConductDialog extends StatelessWidget {
  const CodeOfConductDialog({super.key});

  static const List<String> _intro = [
    'We aim to encourage self-expression, connection and inclusive, creative '
        'discussions.',
    'We\'re focused on helping people find others who are just as passionate '
        'about the same hobby, so they can form artistic relationships and '
        'stay motivated.',
    'The views expressed by users of the webapp are their own and may not '
        'represent the views of PangoPal Inc., its employees, affiliates, or '
        'other users.',
    'To ensure that everyone feels safe and has a positive experience, here '
        'are a few house rules for being part of our online community.',
  ];

  static const List<({String title, String body})> _rules = [
    (
      title: 'Protect privacy',
      body:
          'Avoid posting publicly your personal information. Any posts that '
          'include a phone number, address or other sensitive information will '
          'be removed.',
    ),
    (
      title: 'Be a Pal',
      body:
          'Please avoid posting or sending any hateful, defamatory, obscene, '
          'discriminatory or harassing text or images, or anything that could '
          'be deemed offensive to others. Such content will be removed and '
          'likely lead to permanently banning you from the service.',
    ),
    (
      title: 'Don\'t advertise or self-promote',
      body:
          'Avoid making posts or sending messages that serve as '
          'advertisements for yourself or others. We\'ll remove any links, '
          'images, messages, and so on that advertise or promote the goods or '
          'services of individuals, businesses or causes and such postings '
          'will most likely result in you being banned.',
    ),
    (
      title: 'Don\'t infringe intellectual property',
      body:
          'Avoid posting anything that isn\'t your original creative content '
          'or that you don\'t have a lawful right to post. We love to see what '
          'inspires you, but not at the expense of someone\'s rightful '
          'ownership of their work. Please follow citation rules about citing '
          'the work and content of others. Infringed branded logos, graphics, '
          'copyrighted text or images that come to our attention will be '
          'removed, and you risk being banned.',
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

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onPrimaryContainer,
    );
    final headingStyle = theme.textTheme.titleSmall?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
    );

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
                        for (final (index, paragraph) in _intro.indexed) ...[
                          if (index > 0) const SizedBox(height: 12),
                          Text(paragraph, style: bodyStyle),
                        ],
                        const SizedBox(height: 20),
                        Text('Our Policy:', style: headingStyle),
                        for (final rule in _rules) ...[
                          const SizedBox(height: 16),
                          Text(rule.title, style: headingStyle),
                          const SizedBox(height: 4),
                          Text(rule.body, style: bodyStyle),
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
