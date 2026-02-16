import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bluegps_sdk_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('BlueGPS SDK Demo'), findsOneWidget);
    expect(find.text('Init SDK'), findsOneWidget);
    expect(find.text('Start SSE'), findsOneWidget);
    expect(find.text('Stop SSE'), findsOneWidget);
    expect(find.text('Status: Not initialized'), findsOneWidget);
  });
}
