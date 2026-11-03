// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/animations/motion.dart';
import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/cursor.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/luxury_button.dart';
import '../../core/widgets/pointer_parallax.dart';
import '../../core/widgets/section_title.dart';
import '../../shared/models/rsvp_models.dart';
import '../../shared/painters/burst_painters.dart';
import '../../shared/services/card_generator_service.dart';
import '../../shared/widgets/card_preview_dialog.dart';
import 'rsvp_controller.dart';

class RsvpSection extends StatelessWidget {
  const RsvpSection({super.key});

  @override
  Widget build(BuildContext context) => SceneSection(
    index: Sec.rsvp,
    builder: (c, p, size) => _RsvpStage(p: p, size: size),
  );
}

class _RsvpStage extends ConsumerStatefulWidget {
  const _RsvpStage({required this.p, required this.size});
  final double p;
  final Size size;

  @override
  ConsumerState<_RsvpStage> createState() => _RsvpStageState();
}

class _RsvpStageState extends ConsumerState<_RsvpStage> {
  late final _name = TextEditingController();
  late final _email = TextEditingController();
  late final _phone = TextEditingController();
  late final _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(rsvpControllerProvider);
    _name.text = s.name;
    _email.text = s.email;
    _phone.text = s.phone;
    _message.text = s.message;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  void _clear() {
    _name.clear();
    _email.clear();
    _phone.clear();
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(rsvpControllerProvider);
    final ctl = ref.read(rsvpControllerProvider.notifier);
    final wide = widget.size.width >= 900;
    final success = s.status == RsvpStatus.success;

    final form = GlassPanel(
      key: const ValueKey('form'),
      radius: 36,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 40 : 16,
        vertical: wide ? 40 : 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            'Full name',
            _name,
            ctl.setName,
            s.showErrors ? s.nameError : null,
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: wide ? 14 : 10),
          wide
              ? Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Email (optional)',
                        _email,
                        ctl.setEmail,
                        s.showErrors ? s.emailError : null,
                        type: TextInputType.emailAddress,
                        helperText: 'Give email if you want wedding photos',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        'Contact number',
                        _phone,
                        ctl.setPhone,
                        s.showErrors ? s.phoneError : null,
                        type: TextInputType.phone,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _field(
                      'Email (optional)',
                      _email,
                      ctl.setEmail,
                      s.showErrors ? s.emailError : null,
                      type: TextInputType.emailAddress,
                      helperText: 'Give email if you want wedding photos',
                    ),
                    const SizedBox(height: 10),
                    _field(
                      'Contact number',
                      _phone,
                      ctl.setPhone,
                      s.showErrors ? s.phoneError : null,
                      type: TextInputType.phone,
                    ),
                  ],
                ),
          SizedBox(height: wide ? 20 : 14),
          Row(
            children: [
              Expanded(
                child: _Choice(
                  label: 'Joyfully accepts',
                  selected: s.attendance == Attendance.accepts,
                  compact: !wide,
                  onTap: () => ctl.setAttendance(Attendance.accepts),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Choice(
                  label: 'Regretfully declines',
                  selected: s.attendance == Attendance.declines,
                  compact: !wide,
                  onTap: () => ctl.setAttendance(Attendance.declines),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Motion.cinematic,
            child: s.attendance == Attendance.accepts
                ? Padding(
                    padding: EdgeInsets.only(top: wide ? 18 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Which events will you attend?',
                          style: LuxText.serif(
                            wide ? 16 : 14.5,
                            weight: FontWeight.w600,
                            color: Lux.dark.withValues(alpha: .85),
                          ),
                        ),
                        SizedBox(height: wide ? 10 : 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _EventChoice(
                              label: 'Both Celebrations',
                              sublabel: 'Wedding & Reception',
                              selected: s.events == AttendingEvents.both,
                              compact: !wide,
                              onTap: () => ctl.setEvents(AttendingEvents.both),
                            ),
                            _EventChoice(
                              label: 'Wedding Ceremony Only',
                              sublabel: '13 Dec · Shubho Bibaho',
                              selected: s.events == AttendingEvents.weddingOnly,
                              compact: !wide,
                              onTap: () => ctl.setEvents(AttendingEvents.weddingOnly),
                            ),
                            _EventChoice(
                              label: 'Reception Gala Only',
                              sublabel: '15 Dec · Bou Bhaat',
                              selected: s.events == AttendingEvents.receptionOnly,
                              compact: !wide,
                              onTap: () => ctl.setEvents(AttendingEvents.receptionOnly),
                            ),
                          ],
                        ),
                        SizedBox(height: wide ? 18 : 12),
                        Row(
                          children: [
                            Text(
                              'Guests',
                              style: LuxText.serif(
                                wide ? 20 : 17,
                                style: FontStyle.normal,
                                color: Lux.dark.withValues(alpha: .7),
                              ),
                            ),
                            const Spacer(),
                            _Step(
                              icon: Icons.remove_rounded,
                              onTap: () => ctl.setGuests(s.guests - 1),
                            ),
                            SizedBox(
                              width: 52,
                              child: Text(
                                '${s.guests}',
                                textAlign: TextAlign.center,
                                style: LuxText.display(wide ? 26 : 22),
                              ),
                            ),
                            _Step(
                              icon: Icons.add_rounded,
                              onTap: () => ctl.setGuests(s.guests + 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          SizedBox(height: wide ? 18 : 12),
          _field(
            'A note for the couple',
            _message,
            ctl.setMessage,
            null,
            lines: wide ? 3 : 2,
          ),
          SizedBox(height: wide ? 26 : 18),
          if (s.status == RsvpStatus.failure)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'We couldn’t send your reply. Check your connection and try again.',
                textAlign: TextAlign.center,
                style: LuxText.body(
                  13,
                  color: const Color(0xFFB3463B),
                  opacity: 1,
                ),
              ),
            ),
          Center(
            child: LuxuryButton(
              label: 'Send my reply',
              compact: !wide,
              loading: s.status == RsvpStatus.submitting,
              onPressed: ctl.submit,
            ),
          ),
        ],
      ),
    );

    final thanks =
        GlassPanel(
              key: const ValueKey('thanks'),
              radius: 36,
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 48 : 20,
                vertical: wide ? 48 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: wide ? 74 : 52,
                    height: wide ? 74 : 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF1D98C),
                          Lux.gold,
                          Color(0xFFC49A2C),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: wide ? 38 : 26,
                      color: Lux.dark,
                    ),
                  ).animate().scale(
                    begin: const Offset(.3, .3),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.elasticOut,
                  ),
                  SizedBox(height: wide ? 22 : 12),
                  Text(
                    'Thank you, ${s.name.trim().split(' ').first}',
                    textAlign: TextAlign.center,
                    style: LuxText.display(context.fluid(wide ? 30 : 24, 46)),
                  ),
                  SizedBox(height: wide ? 12 : 8),
                  Text(
                    s.attendance == Attendance.accepts
                        ? 'We have saved ${s.guests == 1 ? 'a seat' : '${s.guests} seats'} for you.\nWe can’t wait to celebrate together and receive your warm blessings.'
                        : 'We will miss you dearly, and we’re deeply grateful for your blessings and love.',
                    textAlign: TextAlign.center,
                    style: LuxText.serif(context.fluid(wide ? 18 : 15, 24), height: 1.4),
                  ),
                  SizedBox(height: wide ? 18 : 12),
                  // Card Status Notice Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 18 : 12,
                      vertical: wide ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Lux.gold.withValues(alpha: .14),
                      border: Border.all(color: Lux.gold.withValues(alpha: .7)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.card_giftcard_rounded, size: wide ? 20 : 16, color: Lux.crimson),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                s.attendance == Attendance.accepts
                                    ? 'Your Custom Wedding Invite Card is Ready'
                                    : 'Your Personalized Greeting Card is Ready',
                                style: LuxText.serif(wide ? 15 : 13, weight: FontWeight.w700, color: Lux.crimson),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap below to download or view and save your invitation to your photos.',
                          textAlign: TextAlign.center,
                          style: LuxText.body(wide ? 12 : 11, color: Lux.dark.withValues(alpha: .75)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: wide ? 24 : 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: wide ? 12 : 8,
                    runSpacing: wide ? 10 : 8,
                    children: [
                      LuxuryButton(
                        label: s.attendance == Attendance.accepts
                            ? (wide ? 'Download Invite Card 📥' : 'Download Invite 📥')
                            : (wide ? 'Download Greeting Card 📥' : 'Download Card 📥'),
                        compact: !wide,
                        onPressed: () async {
                          const generator = CardGeneratorService();
                          await generator.generateAndDownload(s.toSubmission());
                        },
                      ),
                      LuxuryButton(
                        label: wide ? 'View / Save Image 👁' : 'View Image 👁',
                        compact: !wide,
                        filled: false,
                        onPressed: () => CardPreviewDialog.show(context, s.toSubmission()),
                      ),
                      LuxuryButton(
                        label: 'Edit reply',
                        compact: !wide,
                        filled: false,
                        onPressed: () {
                          ctl.edit();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 700.ms)
            .moveY(
              begin: 30,
              end: 0,
              duration: 900.ms,
              curve: Motion.cinematic,
            );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              wide ? 0 : 14,
              wide ? 60 : 32,
              wide ? 0 : 14,
              wide ? 60 : 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProgressReveal(
                  progress: widget.p,
                  start: 0.1,
                  end: 0.34,
                  child: SectionTitle(
                    eyebrow: 'Aapnar Upasthiti Kamona Kori · Kindly Reply',
                    title: 'Join our celebration',
                    subtitle: 'Kindly reply by ${WeddingConfig.rsvpBy}',
                  ),
                ),
                SizedBox(height: wide ? 36 : 18),
                ProgressReveal(
                  progress: widget.p,
                  start: 0.2,
                  end: 0.5,
                  dy: 80,
                  dz: 180,
                  blur: 14,
                  child: PointerParallax(
                    smoothing: 4,
                    builder: (c, o, child) => Transform(
                      alignment: Alignment.center,
                      transform: depthMatrix(
                        ry: o.dx * 0.04,
                        rx: -o.dy * 0.03,
                      ),
                      child: child,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 660),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: success ? thanks : form,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (success)
          const Positioned.fill(child: IgnorePointer(child: PetalBurst())),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    ValueChanged<String> on,
    String? err, {
    TextInputType? type,
    int lines = 1,
    IconData? icon,
    String? helperText,
  }) {
    return TextField(
      controller: c,
      onChanged: on,
      keyboardType: type,
      minLines: lines,
      maxLines: lines,
      cursorColor: Lux.gold,
      style: LuxText.body(15.5, opacity: 1),
      decoration: InputDecoration(
        labelText: label,
        errorText: err,
        helperText: helperText,
        helperStyle: LuxText.body(11.5, color: Lux.goldDeep, opacity: 0.9),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });
  final String label;
  final bool selected, compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CursorHover(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Motion.cinematic,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 11 : 16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Lux.gold.withValues(alpha: .18)
              : Colors.white.withValues(alpha: .4),
          border: Border.all(
            color: selected ? Lux.gold : Lux.champagne,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: LuxText.serif(
            compact ? 15 : 18,
            style: FontStyle.normal,
            weight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Lux.goldDeep : Lux.dark,
          ),
        ),
      ),
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CursorHover(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Lux.gold),
        ),
        child: Icon(icon, size: 20, color: Lux.goldDeep),
      ),
    ),
  );
}

class _EventChoice extends StatelessWidget {
  const _EventChoice({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final String sublabel;
  final bool selected, compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CursorHover(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 7 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Lux.gold.withValues(alpha: .22)
              : Colors.white.withValues(alpha: .45),
          border: Border.all(
            color: selected ? Lux.gold : Lux.champagne,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: compact ? 13 : 15,
                  color: selected ? Lux.crimson : Lux.dark.withValues(alpha: .4),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: LuxText.serif(
                    compact ? 12.5 : 14,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Lux.crimson : Lux.dark,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: compact ? 19 : 21, top: 1),
              child: Text(
                sublabel,
                style: LuxText.body(
                  compact ? 10.5 : 11.5,
                  color: selected ? Lux.goldDeep : Lux.dark.withValues(alpha: .6),
                  opacity: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
