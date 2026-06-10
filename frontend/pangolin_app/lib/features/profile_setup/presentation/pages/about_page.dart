import 'package:flutter/material.dart';

import 'package:pangolin_app/features/profile_setup/widgets/add_chip_button.dart';
import 'package:pangolin_app/features/profile_setup/widgets/passion_meter.dart';
import 'package:pangolin_app/features/profile_setup/widgets/section_title.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class AboutPage extends StatefulWidget {
  final VoidCallback onNext;
  final ProfileBuilder profileBuilder;
  const AboutPage({
    super.key,
    required this.onNext,
    required this.profileBuilder,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _additionalInfoExpanded = false;
  final _newSubInterestController = TextEditingController();
  final _newOtherInterestController = TextEditingController();

  @override
  void dispose() {
    _newSubInterestController.dispose();
    _newOtherInterestController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onNext();
    }
  }

  void _showAddInterestDialog(
    BuildContext context,
    TextEditingController controller,
    VoidCallback onAdd,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add interest'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter interest'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onAdd();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.profileBuilder;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('About your craft'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const AppIcon(AppIconType.save),
            tooltip: 'Save',
            onPressed: _onNext,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'This information will be used to find compatible people',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Hobby'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: builder.hobby,
                  hint: const Text('Select a hobby'),
                  decoration: const InputDecoration(),
                  validator: (val) =>
                      val == null ? 'Please select a hobby' : null,
                  onChanged: (val) {
                    if (val != null) builder.setHobby(val);
                  },
                  onSaved: (val) {
                    if (val != null) builder.setHobby(val);
                  },
                  items: ["Painting", "Pottery", "Photography", "Knitting"]
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                ),
                _divider,
                const SectionTitle('Passion-meter'),
                const SizedBox(height: 8),
                FormField<double>(
                  initialValue: builder.passionLevel ?? 0.5,
                  onSaved: (val) {
                    if (val != null) builder.setPassionLevel(val);
                  },
                  builder: (field) {
                    return PassionMeter(
                      value: field.value ?? 0.5,
                      onChanged: (val) {
                        field.didChange(val);
                        builder.setPassionLevel(val);
                      },
                    );
                  },
                ),
                _divider,

                // --- Additional Info (optional, collapsible) ---
                _AdditionalInfoSection(
                  expanded: _additionalInfoExpanded,
                  onToggle: () => setState(
                    () => _additionalInfoExpanded = !_additionalInfoExpanded,
                  ),
                  subInterests: builder.subInterests,
                  otherInterests: builder.otherInterests,
                  onAddSubInterest: () => _showAddInterestDialog(
                    context,
                    _newSubInterestController,
                    () {
                      final text = _newSubInterestController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() => builder.addSubInterest(text));
                        _newSubInterestController.clear();
                      }
                    },
                  ),
                  onRemoveSubInterest: (interest) =>
                      setState(() => builder.removeSubInterest(interest)),
                  onAddOtherInterest: () => _showAddInterestDialog(
                    context,
                    _newOtherInterestController,
                    () {
                      final text = _newOtherInterestController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() => builder.addOtherInterest(text));
                        _newOtherInterestController.clear();
                      }
                    },
                  ),
                  onRemoveOtherInterest: (interest) =>
                      setState(() => builder.removeOtherInterest(interest)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// TODO: beware of repetition here. shared with profile edit page
// --- Additional Info section ---
// Not wrapped in FormField widgets because all fields here are optional.
/// ^ TODO: is this a good reason?

class _AdditionalInfoSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<String> subInterests;
  final List<String> otherInterests;
  final VoidCallback onAddSubInterest;
  final ValueChanged<String> onRemoveSubInterest;
  final VoidCallback onAddOtherInterest;
  final ValueChanged<String> onRemoveOtherInterest;

  const _AdditionalInfoSection({
    required this.expanded,
    required this.onToggle,
    required this.subInterests,
    required this.otherInterests,
    required this.onAddSubInterest,
    required this.onRemoveSubInterest,
    required this.onAddOtherInterest,
    required this.onRemoveOtherInterest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header (always visible) ---
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              AppIcon(
                expanded ? AppIconType.expandLess : AppIconType.expandMore,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              const SectionTitle('Other interests'),
            ],
          ),
        ),

        // --- Expandable body ---//
        if (expanded) ...[
          const SizedBox(height: 16),

          // Sub-interests
          Text('Niche hobby interests', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in subInterests)
                InputChip(
                  label: Text(interest),
                  onDeleted: () => onRemoveSubInterest(interest),
                ),
              AddChipButton(onPressed: onAddSubInterest),
            ],
          ),

          const SizedBox(height: 20),

          // Other interests
          Text('Non-hobby interests', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in otherInterests)
                InputChip(
                  label: Text(interest),
                  onDeleted: () => onRemoveOtherInterest(interest),
                ),
              AddChipButton(onPressed: onAddOtherInterest),
            ],
          ),
        ],
      ],
    );
  }
}

// const _divider = Divider(
//       height: 40,
//       indent: 20,
//       endIndent: 20,
//     );

const _divider = SizedBox(height: 36);
