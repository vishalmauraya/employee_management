import 'package:flutter_test/flutter_test.dart';

import 'package:employee_task_manager/app.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EmployeeTaskApp());
    await tester.pump();

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}
