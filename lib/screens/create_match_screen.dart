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
  TimeOfDay _time = _roundToHalfHour(
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 2))));
  int _durationMinutes = 60;
  int _totalSpots = 4;
  int _guestCount = 0;
  bool _isUnlimited = false;
  bool _isSubmitting = false;

  static TimeOfDay _roundToHalfHour(TimeOfDay t) {
    final minute = t.minute >= 30 ? 30 : 0;
    return TimeOfDay(hour: t.hour, minute: minute);
  }

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
            const _SectionLabel('Duration'),
            const SizedBox(height: 12),
            _DurationStepper(
              minutes: _durationMinutes,
              onChanged: (v) => setState(() => _durationMinutes = v),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Players'),
            const SizedBox(height: 12),
            // Unlimited toggle
            _UnlimitedToggle(
              value: _isUnlimited,
              onChanged: (v) => setState(() {
                _isUnlimited = v;
                if (v) _guestCount = 0;
              }),
            ),
            // Spots + guest steppers only for limited matches
            if (!_isUnlimited) ...[
              const SizedBox(height: 12),
              _SpotsStepper(
                value: _totalSpots,
                onChanged: (v) => setState(() {
                  _totalSpots = v;
                  if (_guestCount >= v) _guestCount = v - 1;
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
            ],
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
              isUnlimited: _isUnlimited,
              durationMinutes: _durationMinutes,
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
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GameOnBrand.slateDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TimePickerSheet(initial: _time),
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
          isUnlimited: _isUnlimited,
          durationMinutes: _durationMinutes,
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
              color: isSelected ? GameOnBrand.saffron : GameOnBrand.slateCard,
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
                Text(sport.emoji, style: const TextStyle(fontSize: 18)),
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

// ─── Unlimited toggle ──────────────────────────────────────────────────────

class _UnlimitedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _UnlimitedToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: GameOnBrand.slateCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? GameOnBrand.saffron.withValues(alpha: 0.5)
                : GameOnBrand.slateLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.all_inclusive_rounded,
              size: 20,
              color: value
                  ? GameOnBrand.saffron
                  : Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlimited spots',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: value
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Anyone can join — no cap',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: GameOnBrand.saffron,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  color: value > 0
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
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
  final bool isUnlimited;
  final int durationMinutes;

  const _MatchPreview({
    required this.sport,
    required this.skillLevel,
    required this.location,
    required this.dateTime,
    required this.totalSpots,
    required this.guestCount,
    required this.isUnlimited,
    required this.durationMinutes,
  });

  String get _durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final filledSpots = 1 + guestCount;

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
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(
                          location,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.55)),
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
                  const SizedBox(width: 8),
                  Icon(Icons.timer_outlined,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 3),
                  Text(
                    _durationLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isUnlimited)
                    Row(
                      children: [
                        Icon(Icons.all_inclusive_rounded,
                            size: 16,
                            color: GameOnBrand.saffron.withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Text(
                          'Unlimited — open to all',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.55)),
                        ),
                      ],
                    )
                  else
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
                              dotColor = GameOnBrand.saffron;
                            } else if (i < filledSpots) {
                              dotColor = GameOnBrand.saffron
                                  .withValues(alpha: 0.5);
                            } else {
                              dotColor = GameOnBrand.saffron
                                  .withValues(alpha: 0.18);
                            }
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 10,
                              height: 10,
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

// ─── Duration stepper ──────────────────────────────────────────────────────

class _DurationStepper extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DurationStepper({required this.minutes, required this.onChanged});

  String get _label {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: GameOnBrand.slateLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined,
              size: 18, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Duration',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: minutes > 30 ? () => onChanged(minutes - 30) : null,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              _label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GameOnBrand.saffron,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: minutes < 300 ? () => onChanged(minutes + 30) : null,
          ),
        ],
      ),
    );
  }
}

// ─── Custom time picker sheet ───────────────────────────────────────────────

class _TimePickerSheet extends StatefulWidget {
  final TimeOfDay initial;
  const _TimePickerSheet({required this.initial});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _hourCtrl = FixedExtentScrollController(initialItem: widget.initial.hour);
    _minuteCtrl = FixedExtentScrollController(
        initialItem: widget.initial.minute >= 30 ? 1 : 0);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select time',
              style:
                  TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight band
                Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: GameOnBrand.saffron.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: GameOnBrand.saffron.withValues(alpha: 0.3)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour wheel
                    SizedBox(
                      width: 90,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourCtrl,
                        itemExtent: 52,
                        perspective: 0.004,
                        diameterRatio: 2,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: List.generate(
                            24,
                            (h) => Center(
                              child: Text(
                                h.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(':',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            color: GameOnBrand.saffron)),
                    // Minute wheel (00 / 30 only)
                    SizedBox(
                      width: 90,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteCtrl,
                        itemExtent: 52,
                        perspective: 0.004,
                        diameterRatio: 2,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: ['00', '30']
                              .map((m) => Center(
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: FilledButton(
              onPressed: () {
                final hour = _hourCtrl.selectedItem % 24;
                final minute = (_minuteCtrl.selectedItem % 2) * 30;
                Navigator.pop(context, TimeOfDay(hour: hour, minute: minute));
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Confirm',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
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
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: GameOnBrand.slateDark),
                )
              : const Text('Create Match',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
