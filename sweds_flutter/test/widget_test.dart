import 'package:flutter_test/flutter_test.dart';
import 'package:sweds_flutter/core/scroll/section_spec.dart';

void main() {
  test('pinned progress scrubs 0..1 across its travel', () {
    const l = SectionLayout(
      SectionSpec('x', 'X', 3, pinned: true),
      1000,
      2700,
      900,
    );
    expect(l.progressAt(1000), 0);
    expect(l.progressAt(1000 + l.pinTravel), 1);
  });
}
