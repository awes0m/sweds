import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/wedding_config.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../../shared/models/rsvp_models.dart';
import '../../shared/providers/app_providers.dart';

class SecretGuestListPage extends ConsumerStatefulWidget {
  const SecretGuestListPage({super.key});

  @override
  ConsumerState<SecretGuestListPage> createState() => _SecretGuestListPageState();
}

class _SecretGuestListPageState extends ConsumerState<SecretGuestListPage> {
  String _searchQuery = '';
  int _tabIndex = 0; // 0 = Attending, 1 = All, 2 = Declined
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copySummary(List<RsvpSubmission> guests) {
    final buffer = StringBuffer();
    buffer.writeln('=== SAYANTIKA & SOM WEDDING GUEST LIST (NOOSU & BUNU) ===');
    buffer.writeln('Total Confirmed Parties: ${guests.where((g) => g.attendance == Attendance.accepts).length}');
    final totalSeats = guests
        .where((g) => g.attendance == Attendance.accepts)
        .fold<int>(0, (sum, g) => sum + (g.guests > 0 ? g.guests : 1));
    buffer.writeln('Total Attending Seats: $totalSeats\n');

    for (final g in guests) {
      final eventStr = g.attendance == Attendance.accepts
          ? (g.events == AttendingEvents.both
              ? 'Both Wedding & Reception'
              : (g.events == AttendingEvents.weddingOnly
                  ? 'Wedding Ceremony Only'
                  : 'Reception Gala Only'))
          : '';
      final status = g.attendance == Attendance.accepts
          ? 'ACCEPTS (${g.guests} seats - $eventStr)'
          : 'DECLINES';
      buffer.writeln('• ${g.name} - $status');
      buffer.writeln('  Contact: ${g.phone}${g.email.isNotEmpty ? ' | ${g.email}' : ''}');
      if (g.message.isNotEmpty) {
        buffer.writeln('  Note: "${g.message}"');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guest list summary copied to clipboard!'),
        backgroundColor: Lux.crimson,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(allSubmissionsProvider);
    final wide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      backgroundColor: Lux.ivory,
      body: Stack(
        children: [
          // Subtle warm decorative background gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFDFBF7),
                    Color(0xFFF9F3E5),
                    Color(0xFFF5EADA),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lux.gold.withValues(alpha: .08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            width: 350,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Lux.crimson.withValues(alpha: .05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 32 : 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top navigation bar
                      Row(
                        children: [
                          LuxuryButton(
                            label: '← Return to Wedding Site',
                            filled: false,
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF1B6B2B).withValues(alpha: .12),
                              border: Border.all(color: const Color(0xFF1B6B2B)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1B6B2B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Live Cloud Firestore',
                                  style: LuxText.body(
                                    12,
                                    color: const Color(0xFF1B6B2B),
                                    opacity: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Header Title Card
                      GlassPanel(
                        radius: 28,
                        padding: EdgeInsets.all(wide ? 24 : 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lock_rounded,
                                        size: 16,
                                        color: Lux.crimson,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SECRET GUEST TRACKER · NOOSU & BUNU',
                                        style: LuxText.eyebrow(Lux.crimson).copyWith(
                                          fontSize: 11,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${WeddingConfig.bride} & ${WeddingConfig.groom} · Guest List',
                                    style: LuxText.display(
                                      wide ? 30 : 22,
                                      color: Lux.crimson,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'শুভ বিবাহ অতিথি ও নিমন্ত্রণ তালিকা · Real-time RSVP Manager',
                                    style: LuxText.serif(
                                      14,
                                      color: Lux.goldDeep,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (wide)
                              guestsAsync.when(
                                data: (list) => LuxuryButton(
                                  label: 'Copy Summary 📋',
                                  filled: true,
                                  onPressed: () => _copySummary(list),
                                ),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Metric Stats & Filter controls
                      guestsAsync.when(
                        data: (submissions) {
                          final accepts = submissions
                              .where((s) => s.attendance == Attendance.accepts)
                              .toList();
                          final declines = submissions
                              .where((s) => s.attendance == Attendance.declines)
                              .toList();
                          final totalSeats = accepts.fold<int>(
                            0,
                            (sum, g) => sum + (g.guests > 0 ? g.guests : 1),
                          );

                          final filteredList = submissions.where((s) {
                            if (_tabIndex == 0 && s.attendance != Attendance.accepts) {
                              return false;
                            }
                            if (_tabIndex == 2 && s.attendance != Attendance.declines) {
                              return false;
                            }
                            if (_searchQuery.isNotEmpty) {
                              final query = _searchQuery.toLowerCase();
                              final matchName = s.name.toLowerCase().contains(query);
                              final matchPhone = s.phone.toLowerCase().contains(query);
                              final matchMsg = s.message.toLowerCase().contains(query);
                              return matchName || matchPhone || matchMsg;
                            }
                            return true;
                          }).toList();

                          return Expanded(
                            child: Column(
                              children: [
                                // Stats Cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _statCard(
                                        'Attending Parties',
                                        '${accepts.length}',
                                        Icons.check_circle_outline_rounded,
                                        Lux.goldDeep,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _statCard(
                                        'Total Guests Attending',
                                        '$totalSeats',
                                        Icons.people_outline_rounded,
                                        Lux.crimson,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _statCard(
                                        'Warm Blessings (Declined)',
                                        '${declines.length}',
                                        Icons.favorite_border_rounded,
                                        const Color(0xFF8B6B1B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Search & Filter Tabs Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (v) => setState(() => _searchQuery = v.trim()),
                                        cursorColor: Lux.gold,
                                        decoration: InputDecoration(
                                          hintText: 'Search guests by name or phone...',
                                          prefixIcon: const Icon(Icons.search_rounded, color: Lux.goldDeep),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() => _searchQuery = '');
                                                  },
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: .6),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Lux.champagne),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Lux.champagne),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Lux.gold, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Tabs Row
                                Row(
                                  children: [
                                    _tabBtn('Attending (${accepts.length})', 0),
                                    const SizedBox(width: 8),
                                    _tabBtn('All Responses (${submissions.length})', 1),
                                    const SizedBox(width: 8),
                                    _tabBtn('Declines (${declines.length})', 2),
                                    if (!wide) ...[
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, color: Lux.crimson),
                                        tooltip: 'Copy summary',
                                        onPressed: () => _copySummary(submissions),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // List of Guests
                                Expanded(
                                  child: filteredList.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32),
                                            child: Text(
                                              _searchQuery.isNotEmpty
                                                  ? 'No guests match "$_searchQuery".'
                                                  : 'No guest RSVPs received yet in this category.',
                                              textAlign: TextAlign.center,
                                              style: LuxText.serif(16, color: Lux.dark.withValues(alpha: .7)),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: filteredList.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                                          itemBuilder: (context, i) {
                                            final g = filteredList[i];
                                            final isAccept = g.attendance == Attendance.accepts;

                                            return GlassPanel(
                                              radius: 20,
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Avatar Circle
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: isAccept
                                                            ? [const Color(0xFFF1D98C), Lux.gold]
                                                            : [const Color(0xFFE2D6CA), const Color(0xFFC7B6A5)],
                                                      ),
                                                      border: Border.all(
                                                        color: isAccept ? Lux.goldDeep : Lux.champagne,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      g.name.isNotEmpty ? g.name.trim()[0].toUpperCase() : '?',
                                                      style: LuxText.serif(
                                                        20,
                                                        weight: FontWeight.bold,
                                                        color: isAccept ? Lux.crimson : Lux.dark,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14),

                                                  // Guest Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                g.name,
                                                                style: LuxText.serif(
                                                                  18,
                                                                  weight: FontWeight.w700,
                                                                  color: Lux.dark,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 3,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(12),
                                                                color: isAccept
                                                                    ? Lux.gold.withValues(alpha: .22)
                                                                    : Colors.grey.withValues(alpha: .2),
                                                              ),
                                                              child: Text(
                                                                isAccept
                                                                    ? (g.guests == 1
                                                                        ? '1 Seat Reserved'
                                                                        : '${g.guests} Seats Reserved')
                                                                    : 'Declined with love',
                                                                style: LuxText.body(
                                                                  12,
                                                                  weight: FontWeight.w700,
                                                                  color: isAccept ? Lux.goldDeep : Lux.dark.withValues(alpha: .7),
                                                                  opacity: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            if (isAccept) ...[
                                                              const SizedBox(width: 6),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 3,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  color: Lux.crimson.withValues(alpha: .1),
                                                                  border: Border.all(
                                                                    color: Lux.crimson.withValues(alpha: .3),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  g.events == AttendingEvents.both
                                                                      ? 'Both Events'
                                                                      : (g.events == AttendingEvents.weddingOnly
                                                                          ? 'Wedding Only'
                                                                          : 'Reception Only'),
                                                                  style: LuxText.body(
                                                                    11,
                                                                    weight: FontWeight.w600,
                                                                    color: Lux.crimson,
                                                                    opacity: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        const SizedBox(height: 4),

                                                        // Contact row
                                                        Wrap(
                                                          spacing: 16,
                                                          runSpacing: 4,
                                                          children: [
                                                            if (g.phone.isNotEmpty)
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.phone_outlined, size: 14, color: Lux.goldDeep),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    g.phone,
                                                                    style: LuxText.body(13, color: Lux.dark.withValues(alpha: .85)),
                                                                  ),
                                                                ],
                                                              ),
                                                            if (g.email.isNotEmpty)
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  const Icon(Icons.email_outlined, size: 14, color: Lux.goldDeep),
                                                                  const SizedBox(width: 4),
                                                                  Text(
                                                                    g.email,
                                                                    style: LuxText.body(13, color: Lux.dark.withValues(alpha: .85)),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),

                                                        // Personal Note / Blessing
                                                        if (g.message.isNotEmpty) ...[
                                                          const SizedBox(height: 8),
                                                          Container(
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFF7EEDD).withValues(alpha: .7),
                                                              borderRadius: BorderRadius.circular(10),
                                                              border: Border.all(
                                                                color: Lux.champagne.withValues(alpha: .6),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              '“${g.message}”',
                                                              style: LuxText.serif(
                                                                14,
                                                                style: FontStyle.italic,
                                                                color: Lux.dark.withValues(alpha: .9),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(color: Lux.gold),
                          ),
                        ),
                        error: (err, st) => Expanded(
                          child: Center(
                            child: Text(
                              'Failed to load guest list: $err',
                              style: LuxText.body(14, color: const Color(0xFFB3463B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Lux.gold.withValues(alpha: .4)),
        boxShadow: [
          BoxShadow(
            color: Lux.dark.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuxText.body(11, color: Lux.dark.withValues(alpha: .7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: LuxText.display(24, color: color),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? Lux.gold : Colors.white.withValues(alpha: .5),
          border: Border.all(
            color: active ? Lux.goldDeep : Lux.champagne,
          ),
        ),
        child: Text(
          label,
          style: LuxText.serif(
            13,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Lux.dark : Lux.dark.withValues(alpha: .75),
          ),
        ),
      ),
    );
  }
}
