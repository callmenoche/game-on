import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/game_on_logo.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();

  SportType _sport = SportType.football;
  SkillLevel _skillLevel = SkillLevel.allLevels;
  DateTime _date = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _time = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(hours: 2)));
  int _totalSpots = 4;
  int _guestCount = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime => DateTime(
        _date.year, _date.month, _date.day,
        _time.hour, _time.minute,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match',
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const _SectionLabel('Sport'),
            const SizedBox(height: 12),
            _SportPicker(
              selected: _sport,
              onChanged: (s) => setState(() => _sport = s),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Skill level'),
            const SizedBox(height: 12),
            _SkillLevelPicker(
              selected: _skillLevel,
              onChanged: (s) => setState(() => _skillLevel = s),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Location'),
            const SizedBox(height: 12),
            _LocationField(controller: _locationController),
            const SizedBox(height: 24),
            const _SectionLabel('Date & Time'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    icon: Icons.calendar_today_rounded,
                    label: DateFormat('EEE, d MMM yyyy').format(_date),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerButton(
                    icon: Icons.access_time_rounded,
                    label: _time.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Total players (including you)'),
            const SizedBox(height: 12),
            _SpotsStepper(
              value: _totalSpots,
              onChanged: (v) => setState(() {
                _totalSpots = v;
                // Clamp guest count if total spots decreased
                if (_guestCount >= _totalSpots) {
                  _guestCount = (_totalSpots - 1).clamp(0, _totalSpots - 1);
                }
              }),
            ),
            const SizedBox(height: 16),
            const _SectionLabel('Bring friends (guests)'),
            const SizedBox(height: 12),
            _GuestCountStepper(
              value: _guestCount,
              max: _totalSpots - 1,
              onChanged: (v) => setState(() => _guestCount = v),
            ),
            const SizedBox(height: 24),
            _MatchPreview(
              sport: _sport,
              skillLevel: _skillLevel,
              location: _locationController.text.isEmpty
                  ? 'Your location'
                  : _locationController.text,
              dateTime: _combinedDateTime,
              totalSpots: _totalSpots,
              guestCount: _guestCount,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SubmitBar(
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: GameOnBrand.saffron),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: GameOnBrand.saffron),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await context.read<MatchProvider>().createMatch(
          sport: _sport,
          location: _locationController.text.trim(),
          dateTime: _combinedDateTime,
          totalSpots: _totalSpots,
          skillLevel: _skillLevel,
          guestCount: _guestCount,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match created! 🎉'),
          backgroundColor: GameOnBrand.saffron,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create match. Try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// ─── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

// ─── Sport picker ──────────────────────────────────────────────────────────

class _SportPicker extends StatelessWidget {
  final SportType selected;
  final ValueChanged<SportType> onChanged;

  const _SportPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: SportType.values.map((sport) {
        final isSelected = sport == selected;
        return GestureDetector(
          onTap: () => onChanged(sport),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? GameOnBrand.saffron
                  : GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? GameOnBrand.saffron
                    : GameOnBrand.slateLight.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sport.emoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  sport.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected
                        ? GameOnBrand.slateDark
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Skill level picker ────────────────────────────────────────────────────

class _SkillLevelPicker extends StatelessWidget {
  final SkillLevel selected;
  final ValueChanged<SkillLevel> onChanged;

  const _SkillLevelPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: SkillLevel.values.map((level) {
        final isSelected = level == selected;
        return GestureDetector(
          onTap: () => onChanged(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? level.color.withValues(alpha: 0.2)
                  : GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? level.color
                    : GameOnBrand.slateLight.withValues(alpha: 0.4),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(level.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  level.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected
                        ? level.color
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Location field ────────────────────────────────────────────────────────

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  const _LocationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'e.g. Parc des Princes, Court 3',
        prefixIcon: Icon(
          Icons.location_on_outlined,
          size: 20,
          color: GameOnBrand.saffron.withValues(alpha: 0.8),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
    );
  }
}

// ─── Date / Time picker button ─────────────────────────────────────────────

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: GameOnBrand.slateCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: GameOnBrand.slateLight.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: GameOnBrand.saffron),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Spots stepper ─────────────────────────────────────────────────────────

class _SpotsStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _SpotsStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: GameOnBrand.slateLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$value players',
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: value > 2 ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: GameOnBrand.saffron,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: value < 22 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Guest count stepper ───────────────────────────────────────────────────

class _GuestCountStepper extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _GuestCountStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  String get _label => switch (value) {
        0 => 'No guests',
        1 => '1 guest',
        _ => '$value guests',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value > 0
              ? GameOnBrand.saffron.withValues(alpha: 0.4)
              : GameOnBrand.slateLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 18,
                color: value > 0
                    ? GameOnBrand.saffron
                    : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 10),
              Text(
                _label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: value > 0 ? Colors.white : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: value > 0 ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: value > 0
                        ? GameOnBrand.saffron
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? GameOnBrand.saffron.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? GameOnBrand.saffron.withValues(alpha: 0.5)
                : GameOnBrand.slateLight.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? GameOnBrand.saffron
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

// ─── Live preview card ─────────────────────────────────────────────────────

class _MatchPreview extends StatelessWidget {
  final SportType sport;
  final SkillLevel skillLevel;
  final String location;
  final DateTime dateTime;
  final int totalSpots;
  final int guestCount;

  const _MatchPreview({
    required this.sport,
    required this.skillLevel,
    required this.location,
    required this.dateTime,
    required this.totalSpots,
    required this.guestCount,
  });

  @override
  Widget build(BuildContext context) {
    final filledSpots = 1 + guestCount; // creator + guests

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Preview'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GameOnBrand.slateCard,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
              left: BorderSide(color: GameOnBrand.saffron, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(sport.emoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sport.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text(
                          location,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white
                                  .withValues(alpha: 0.55)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameOnBrand.saffron.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('OPEN',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: GameOnBrand.saffron,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: skillLevel.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(skillLevel.emoji,
                                style: const TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Text(
                              skillLevel.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: skillLevel.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('EEE d MMM  •  HH:mm').format(dateTime),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$filledSpots / $totalSpots players',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.55))),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(totalSpots, (i) {
                          Color dotColor;
                          if (i == 0) {
                            dotColor = GameOnBrand.saffron; // creator
                          } else if (i < filledSpots) {
                            dotColor = GameOnBrand.saffron.withValues(alpha: 0.5); // guest
                          } else {
                            dotColor = GameOnBrand.saffron.withValues(alpha: 0.18); // open
                          }
                          return Container(
                            margin: const EdgeInsets.only(right: 5),
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              border: Border.all(
                                  color: GameOnBrand.saffron
                                      .withValues(alpha: 0.4)),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          GameOnBrand.saffron.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Join',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: GameOnBrand.saffron)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Bottom submit bar ─────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitBar({required this.isSubmitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: FilledButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: GameOnBrand.saffron,
            foregroundColor: GameOnBrand.slateDark,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: GameOnBrand.slateDark),
                )
              : const Text('Create Match',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
