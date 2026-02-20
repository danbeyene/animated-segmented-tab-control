import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SegmentedTabControl RTL layout test', (WidgetTester tester) async {
    final tabs = [
      SegmentTab(label: 'Tab 1', flex: 1),
      SegmentTab(label: 'Tab 2', flex: 2),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: DefaultTabController(
              length: 2,
              child: SegmentedTabControl(
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // In RTL, Tab 1 should be on the right (flex 1), Tab 2 on the left (flex 2)
    final tab1Finder = find.text('Tab 1');
    final tab2Finder = find.text('Tab 2');

    expect(tab1Finder, findsNWidgets(2)); // Uncolored + Colored versions
    expect(tab2Finder, findsNWidgets(2));

    final tab1Rect = tester.getRect(tab1Finder.first);
    final tab2Rect = tester.getRect(tab2Finder.first);

    // RTL: tab 1 should be to the right of tab 2
    expect(tab1Rect.left, greaterThan(tab2Rect.right));

    // Verify indicator offset by looking at the ClipPath
    final clipPathFinder = find.byType(ClipPath);
    expect(clipPathFinder, findsOneWidget);
    
    // In RTL, initial index is 0 ('Tab 1'). It has flex 1 out of 3.
    // So its width should be 1/3 of the control width, and it should be on the right.
    // We expect the ClipPath offset.dx to be 2/3 of the control width.
    ClipPath clipPath = tester.widget(clipPathFinder);
    dynamic clipper = clipPath.clipper;
    
    final controlFinder = find.byType(SegmentedTabControl);
    final controlRect = tester.getRect(controlFinder);
    final expectedIndicatorWidth = controlRect.width / 3;
    final expectedOffsetDx = controlRect.width * 2 / 3;

    print('Control width: \${controlRect.width}');
    print('Indicator clipper size: \${clipper.size.width}');
    print('Indicator offset dx: \${clipper.offset.dx}');

    // They might not be exactly equal due to padding, but should be close
    expect((clipper.size.width - expectedIndicatorWidth).abs() < 10, true);
    // The offset dx should be close to 2/3 of the width
    expect((clipper.offset.dx - expectedOffsetDx).abs() < 10, true);

    // Switch to Tab 2
    final defaultTabController = DefaultTabController.of(tester.element(controlFinder));
    defaultTabController.animateTo(1);
    await tester.pumpAndSettle();

    clipPath = tester.widget(clipPathFinder);
    clipper = clipPath.clipper;

    print('Tab 2 - Indicator clipper size: \${clipper.size.width}');
    print('Tab 2 - Indicator offset dx: \${clipper.offset.dx}');
    
    final expectedIndicatorWidth2 = controlRect.width * 2 / 3;
    final expectedOffsetDx2 = 0.0;
    
    expect((clipper.size.width - expectedIndicatorWidth2).abs() < 10, true);
    expect((clipper.offset.dx - expectedOffsetDx2).abs() < 10, true);
  });
}
