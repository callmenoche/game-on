import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../l10n/app_localizations.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/availability_grid.dart';
import '../widgets/game_on_logo.dart';

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
    final joinedMatches  = matchProvider.joinedMatches;
    final selectedEvents = _eventsForDay(_selectedDay, joinedMatches);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myCalendar,
            style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  const AvailabilityGrid(),
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
    final l = AppLocalizations.of(context)!;
    final isToday = isSameDay(day, DateTime.now());
    final locale  = Localizations.localeOf(context).languageCode;
    final label   = isToday ? l.today : DateFormat('EEEE, d MMM', locale).format(day);

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
                  l.noMatchesScheduled,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GameOnBrand.slateCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: match.sportType.color, width: 3)),
      ),
      child: Row(
        children: [
          PhosphorIcon(match.sportType.icon, size: 24, color: GameOnBrand.saffron),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.sportType.l10nLabel(context),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(match.dateTime),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GameOnBrand.saffron.withValues(alpha: 0.85),
                ),
              ),
              Text(
                match.durationLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ],
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
