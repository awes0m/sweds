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
    // The form lives in Riverpod; controllers are rebuilt from it if the
    // section is disposed while scrolled away.
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
      padding: EdgeInsets.all(wide ? 40 : 22),
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
          const SizedBox(height: 14),
          wide
              ? Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Email',
                        _email,
                        ctl.setEmail,
                        s.showErrors ? s.emailError : null,
                        type: TextInputType.emailAddress,
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
                      'Email',
                      _email,
                      ctl.setEmail,
                      s.showErrors ? s.emailError : null,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Contact number',
                      _phone,
                      ctl.setPhone,
                      s.showErrors ? s.phoneError : null,
                      type: TextInputType.phone,
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Choice(
                  label: 'Joyfully accepts',
                  selected: s.attendance == Attendance.accepts,
                  onTap: () => ctl.setAttendance(Attendance.accepts),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Choice(
                  label: 'Regretfully declines',
                  selected: s.attendance == Attendance.declines,
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
                    padding: const EdgeInsets.only(top: 18),
                    child: Row(
                      children: [
                        Text(
                          'Guests',
                          style: LuxText.serif(
                            20,
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
                            style: LuxText.display(26),
                          ),
                        ),
                        _Step(
                          icon: Icons.add_rounded,
                          onTap: () => ctl.setGuests(s.guests + 1),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 18),
          _field(
            'A note for the couple',
            _message,
            ctl.setMessage,
            null,
            lines: 3,
          ),
          const SizedBox(height: 26),
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
              padding: EdgeInsets.all(wide ? 48 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 74,
                    height: 74,
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
                    child: const Icon(
                      Icons.check_rounded,
                      size: 38,
                      color: Lux.dark,
                    ),
                  ).animate().scale(
                    begin: const Offset(.3, .3),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Thank you, ${s.name.trim().split(' ').first}',
                    textAlign: TextAlign.center,
                    style: LuxText.display(context.fluid(30, 46)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.attendance == Attendance.accepts
                        ? 'We have saved ${s.guests == 1 ? 'a seat' : '${s.guests} seats'} for you.\nWe can’t wait to celebrate together and receive your warm blessings.'
                        : 'We will miss you dearly, and we’re deeply grateful for your blessings and love.',
                    textAlign: TextAlign.center,
                    style: LuxText.serif(context.fluid(19, 24), height: 1.45),
                  ),
                  const SizedBox(height: 26),
                  LuxuryButton(
                    label: 'Edit my reply',
                    filled: false,
                    onPressed: () {
                      ctl.edit();
                    },
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
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 0 : 16,
                  vertical: 60,
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
                    const SizedBox(height: 36),
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
  }) {
    return TextField(
      controller: c,
      onChanged: on,
      keyboardType: type,
      minLines: lines,
      maxLines: lines,
      cursorColor: Lux.gold,
      style: LuxText.body(15.5, opacity: 1),
      decoration: InputDecoration(labelText: label, errorText: err),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CursorHover(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Motion.cinematic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            18,
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
