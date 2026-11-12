import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_web/core/widgets/animated_fade_slide.dart';

void main() {
  group('staggerDelay', () {
    test('grows with the index and is capped', () {
      expect(staggerDelay(0), Duration.zero);
      expect(staggerDelay(3), const Duration(milliseconds: 180));
      expect(staggerDelay(50), const Duration(milliseconds: 480));
    });
  });

  group('AnimatedFadeSlide', () {
    testWidgets('is hidden before its delay and fully visible afterwards',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AnimatedFadeSlide(
          delay: Duration(milliseconds: 200),
          child: Text('hello'),
        ),
      ));

      double opacity() => tester
          .widget<Opacity>(find.descendant(
              of: find.byType(AnimatedFadeSlide), matching: find.byType(Opacity)))
          .opacity;

      expect(opacity(), 0.0);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(opacity(), 1.0);
      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('PressableScale', () {
    testWidgets('shrinks while pressed, restores on release and keeps taps working',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: PressableScale(
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(width: 100, height: 100, child: Text('card')),
            ),
          ),
        ),
      ));

      double scale() => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
      expect(scale(), 1.0);

      final gesture = await tester.startGesture(tester.getCenter(find.text('card')));
      await tester.pump();
      expect(scale(), lessThan(1.0));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), 1.0);
      expect(taps, 1, reason: 'the child must still receive the tap');
    });
  });
}
