import 'package:biodiversity/components/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test default edit dialog', (tester) async {
    var abortCalled = false;
    var saveCalled = false;
    var cancelCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: EditDialog(
          title: 'title',
          abortCallback: () => abortCalled = true,
          saveCallback: () => saveCalled = true,
          cancelCallback: () => cancelCalled = true,
          body: const Text('test')),
    ));
    await tester.tap(find.text('Speichern'));
    await tester.tap(find.text('Abbrechen'));
    await tester.tap(find.widgetWithIcon(IconButton, Icons.clear));
    expect(abortCalled, true, reason: 'abort callback was not called');
    expect(saveCalled, true, reason: 'save callback was not called');
    expect(cancelCalled, true, reason: 'cancel callback was not called');
    expect(find.byIcon(Icons.clear), findsNWidgets(2),
        reason: 'Clear cross at the top missing');
  });

  testWidgets('test icon and label change', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditDialog(
          title: 'title',
          save: 'saveTest',
          abort: 'abortTest',
          saveIcon: Icons.copy,
          abortIcon: Icons.copyright,
          abortCallback: () {},
          saveCallback: () {},
          body: const Text('test')),
    ));
    expect(find.text('title'), findsOneWidget, reason: 'title not set');
    expect(find.text('saveTest'), findsOneWidget,
        reason: 'save button text not set');
    expect(find.text('abortTest'), findsOneWidget,
        reason: 'abort button text not set');
    expect(find.byIcon(Icons.copy), findsOneWidget,
        reason: 'save Icon not set');
    expect(find.byIcon(Icons.copyright), findsOneWidget,
        reason: 'abort Icon not set');
  });
}
