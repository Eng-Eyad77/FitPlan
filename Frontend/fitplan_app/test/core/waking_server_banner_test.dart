import 'package:fitplan_app/core/network/slow_requests.dart';
import 'package:fitplan_app/shared/widgets/waking_server_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the banner shows only while a request is slower than the threshold', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: WakingServerBanner(child: SizedBox.expand())),
    ));

    final end = container.read(slowRequestsProvider.notifier).track();

    await tester.pump(SlowRequests.threshold - const Duration(seconds: 1));
    expect(find.text(WakingServerBanner.text), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300)); // the spinner never settles
    expect(find.text(WakingServerBanner.text), findsOneWidget);

    end();
    await tester.pump(const Duration(milliseconds: 300)); // the spinner never settles
    expect(find.text(WakingServerBanner.text), findsNothing);
  });

  testWidgets('a fast request never shows the banner and leaves no count behind', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final slow = container.read(slowRequestsProvider.notifier);

    final end = slow.track();
    await tester.pump(const Duration(seconds: 1));
    end();
    end(); // ending twice must not change the count
    await tester.pump(SlowRequests.threshold);

    expect(container.read(slowRequestsProvider), 0);
  });
}
