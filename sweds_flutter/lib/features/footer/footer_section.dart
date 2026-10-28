import 'package:flutter/material.dart';

import '../../core/animations/reveal.dart';
import '../../core/constants/wedding_config.dart';
import '../../core/scroll/scene_section.dart';
import '../../core/scroll/scroll_engine.dart';
import '../../core/scroll/section_spec.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/luxury_button.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) => SceneSection(
        index: Sec.footer,
        builder: (context, p, size) => Center(
          child: ProgressReveal(
            progress: p,
            start: 0.3,
            end: 0.7,
            blur: 12,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Lux.crimson, Lux.gold, Lux.goldLight, Lux.crimson],
                ).createShader(r),
                child: Text('S & S', style: LuxText.display(context.fluid(80, 180), color: Colors.white, style: FontStyle.italic)),
              ),
              const SizedBox(height: 12),
              Text('Shubho Bibaho · With all our love & family blessings,', style: LuxText.serif(context.fluid(18, 26))),
              const SizedBox(height: 6),
              Text('${WeddingConfig.bride} & ${WeddingConfig.groom}', style: LuxText.display(context.fluid(26, 38))),
              const SizedBox(height: 18),
              Text(WeddingConfig.hashtag, style: LuxText.serif(20, style: FontStyle.normal, spacing: 4, color: Lux.crimson, weight: FontWeight.w600)),
              const SizedBox(height: 30),
              LuxuryButton(
                label: 'Back to the beginning',
                filled: false,
                onPressed: () => ScrollEngineScope.of(context).animateTo(0, stiffness: 2.6),
              ),
            ]),
          ),
        ),
      );
}
