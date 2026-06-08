import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/hobby_model.dart';
// import '../../providers/profile_provider.dart';
// import '../../widgets/passion_meter.dart';
// import '../../widgets/interest_chip.dart';
import '../providers/profile_setup_provider.dart';

class AboutPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const AboutPage({super.key, required this.onNext});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _additionalInfoExpanded = false;
  final _newSubInterestController   = TextEditingController();
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
    final profile  = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final theme    = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- Hobby ---
                Text('Hobby', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  // initialValue: (profile?.hobby.isEmpty ?? true) ? null : profile?.hobby, /// TODO
                  initialValue: null,
                  hint: const Text('Select a hobby'),
                  decoration: const InputDecoration(),
                  validator: (val) =>
                      val == null ? 'Please select a hobby' : null,
                  // onChanged is required by DropdownButtonFormField to
                  // update the displayed value. We mirror it to the
                  // provider so the rest of the UI stays in sync.
                  onChanged: (val) {
                    if (val != null) notifier.updateHobby(val);
                  },
                  onSaved: (val) {
                    if (val != null) notifier.updateHobby(val);
                  },
                  /// TODO: this absolutely needs to be abstracted somewhere to a HobbyModel
                  /// but I want simple for now so I'm hardcoding it here. PLEASE CHANGE.
                  items: ["Painting", "Pottery", "Photography", "Knitting"]
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(h),
                              ))
                          .toList(),
                ),
                _divider,

                // --- Passion-meter ---
                Text('Passion-meter', style: theme.textTheme.titleMedium),
                _divider,
                /// TODO
                // FormField<double>(
                //   initialValue: profile?.passionLevel ?? 0.5,
                //   validator: (val) =>
                //       val == null ? 'Please set your passion level' : null,
                //   onSaved: (val) {
                //     if (val != null) notifier.updatePassionLevel(val);
                //   },
                //   builder: (FormFieldState<double> field) {
                //     /// TODO: check the below is actually true
                //     // InputDecorator applies errorText styling from the
                //     // theme automatically — identical to how TextField
                //     // and DropdownButtonFormField render their errors.
                //     return InputDecorator(
                //       decoration: InputDecoration(
                //         errorText: field.errorText,
                //         border: InputBorder.none,
                //         contentPadding: EdgeInsets.zero,
                //       ),
                //       child: PassionMeter(
                //         value: field.value ?? 0.5,
                //         onChanged: (val) {
                //           field.didChange(val);
                //           // Update provider immediately so the rest of
                //           // the UI stays in sync while the user drags.
                //           notifier.updatePassionLevel(val);
                //         },
                //       ),
                //     );
                //   },
                // ),
                _divider,

                // --- Additional Info (optional, collapsible) ---
                _AdditionalInfoSection(
                  expanded: _additionalInfoExpanded,
                  onToggle: () => setState(
                      () => _additionalInfoExpanded = !_additionalInfoExpanded),
                  /// TODO:
                  // subInterests:   profile?.subInterests   ?? [],
                  // otherInterests: profile?.otherInterests ?? [],
                  subInterests:   [],
                  otherInterests: [],
                  onAddSubInterest: () => _showAddInterestDialog(
                    context,
                    _newSubInterestController,
                    () {
                      final text = _newSubInterestController.text.trim();
                      if (text.isNotEmpty) {
                        notifier.addSubInterest(text);
                        _newSubInterestController.clear();
                      }
                    },
                  ),
                  onRemoveSubInterest:   notifier.removeSubInterest,
                  onAddOtherInterest: () => _showAddInterestDialog(
                    context,
                    _newOtherInterestController,
                    () {
                      final text = _newOtherInterestController.text.trim();
                      if (text.isNotEmpty) {
                        notifier.addOtherInterest(text);
                        _newOtherInterestController.clear();
                      }
                    },
                  ),
                  onRemoveOtherInterest: notifier.removeOtherInterest,
                ),
              ],
            ),
          ),
        ),

        // --- Floating 'Next' Button ---
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: _onNext,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ),
      ],
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
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Additional Info (optional)',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),

        // --- Expandable body ---
        if (expanded) ...[
          const SizedBox(height: 16),

          // Sub-interests
          Text('Sub-interests', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              /// TODO: add chips back in
              // ...subInterests.map((s) => InterestChip(
              //       label: s,
              //       onRemove: () => onRemoveSubInterest(s),
              //     )),
              _AddChipButton(onPressed: onAddSubInterest),
            ],
          ),
          const SizedBox(height: 20),

          // Other interests
          Text('Other Interests', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              /// TODO: add chips back in
              // ...otherInterests.map((s) => InterestChip(
              //       label: s,
              //       onRemove: () => onRemoveOtherInterest(s),
              //     )),
              _AddChipButton(onPressed: onAddOtherInterest),
            ],
          ),
        ],
      ],
    );
  }
}

// --- Small helper widgets ---

class _AddChipButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddChipButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: Icon(Icons.add, size: 18, color: colorScheme.primary),
      ),
    );
  }
}

// const _divider = Divider(
//       height: 40,
//       indent: 20,
//       endIndent: 20,
//     );

const _divider = SizedBox(height: 36);
