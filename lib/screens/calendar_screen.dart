import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/game_on_logo.dart';

// ─── Availability metadata ─────────────────────────────────────────────────

const _weekdays = [
  ('monday',    'Mon'),
  ('tuesday',   'Tue'),
  ('wednesday', 'Wed'),
  ('thursday',  'Thu'),
  ('friday',    'Fri'),
  ('saturday',  'Sat'),
  ('sunday',    'Sun'),
];

const _slots = [
  ('morning',   '☀️', 'Morning'),
  ('afternoon', '🌤', 'Afternoon'),
  ('evening',   '🌙', 'Evening'),
];

// ─── Screen ────────────────────────────────────────────────────────────────

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  List<Match> _eventsForDay(DateTime day, List<Match> joined) {
    return joined.where((m) =>
        m.dateTime.year == day.year &&
        m.dateTime.month == day.month &&
        m.dateTime.day == day.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider  = context.watch<MatchProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final joinedMatches  = matchProvider.joinedMatches;
    final selectedEvents = _eventsForDay(_selectedDay, joinedMatches);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calendar',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // ── Calendar ──────────────────────────────────────────────────────
          TableCalendar<Match>(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay  = focused;
            }),
            onFormatChanged: (f) => setState(() => _calendarFormat = f),
            onPageChanged: (focused) => _focusedDay = focused,
            eventLoader: (day) => _eventsForDay(day, joinedMatches),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: GameOnBrand.saffron.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: GameOnBrand.saffron,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: GameOnBrand.saffron,
                fontWeight: FontWeight.w800,
              ),
              selectedTextStyle: const TextStyle(
                color: GameOnBrand.slateDark,
                fontWeight: FontWeight.w800,
              ),
              defaultTextStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85)),
              weekendTextStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7)),
              markerDecoration: const BoxDecoration(
                color: GameOnBrand.saffron,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(
                    color: GameOnBrand.saffron.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(
                color: GameOnBrand.saffron,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                  color: GameOnBrand.saffron),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                  color: GameOnBrand.saffron),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              weekendStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: GameOnBrand.saffron.withValues(alpha: 0.6),
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Bottom panel ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SelectedDaySection(
                    day: _selectedDay,
                    matches: selectedEvents,
                  ),
                  const SizedBox(height: 28),
                  _AvailabilitySection(provider: profileProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selected day section ──────────────────────────────────────────────────

class _SelectedDaySection extends StatelessWidget {
  final DateTime day;
  final List<Match> matches;

  const _SelectedDaySection({required this.day, required this.matches});

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(day, DateTime.now());
    final label   = isToday ? 'Today' : DateFormat('EEEE, d MMM').format(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 12),
        if (matches.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available_rounded,
                    size: 18, color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(width: 12),
                Text(
                  'No matches scheduled',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.35)),
                ),
              ],
            ),
          )
        else
          ...matches.map((m) => _MatchEventRow(match: m)),
      ],
    );
  }
}

class _MatchEventRow extends StatelessWidget {
  final Match match;
  const _MatchEventRow({required this.match});

  Color get _sportColor => switch (match.sportType) {
        SportType.padel      => const Color(0xFF00C2A8),
        SportType.football   => const Color(0xFF4CAF50),
        SportType.basketball => const Color(0xFFFF6B2B),
        SportType.tennis     => const Color(0xFFD4E157),
        SportType.running    => const Color(0xFF42A5F5),
        SportType.cycling    => const Color(0xFFAB47BC),
        SportType.other      => GameOnBrand.saffron,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _sportColor, width: 3)),
      ),
      child: Row(
        children: [
          Text(match.sportType.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.sportType.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  match.locationName,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            DateFormat('HH:mm').format(match.dateTime),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: GameOnBrand.saffron.withValues(alpha: 0.85),
            ),
          ),
          if (match.isConfirmed) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle_rounded,
                size: 14, color: Colors.green.shade400),
          ],
        ],
      ),
    );
  }
}

// ─── Weekly availability section ───────────────────────────────────────────

class _AvailabilitySection extends StatelessWidget {
  final ProfileProvider provider;
  const _AvailabilitySection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Weekly Availability'),
        const SizedBox(height: 4),
        Text(
          'When are you usually free to play?',
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 14),
        if (provider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: GameOnBrand.saffron),
            ),
          )
        else ...[
          // Grid
          Container(
            decoration: BoxDecoration(
              color: GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: _weekdays.asMap().entries.map((entry) {
                final i = entry.key;
                final (day, label) = entry.value;
                final isWeekend = day == 'saturday' || day == 'sunday';
                final isLast = i == _weekdays.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 34,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isWeekend
                                    ? GameOnBrand.saffron
                                        .withValues(alpha: 0.75)
                                    : Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _slots.map((s) {
                                final (slot, emoji, _) = s;
                                final active = provider.isAvailable(day, slot);
                                return _SlotChip(
                                  emoji: emoji,
                                  active: active,
                                  onTap: () => provider.toggleSlot(day, slot),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: GameOnBrand.slateLight.withValues(alpha: 0.25),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Legend
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _slots.map((s) {
              final (_, emoji, label) = s;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.35)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ─── Slot chip ─────────────────────────────────────────────────────────────

class _SlotChip extends StatelessWidget {
  final String emoji;
  final bool active;
  final VoidCallback onTap;

  const _SlotChip({
    required this.emoji,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 38,
        decoration: BoxDecoration(
          color: active
              ? GameOnBrand.saffron.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? GameOnBrand.saffron.withValues(alpha: 0.6)
                : GameOnBrand.slateLight.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 17,
              color: active ? null : null, // emoji colour handles itself
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────

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
