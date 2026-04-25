import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:klaro/main.dart';

void main() {
  testWidgets('Klaro app widget can be constructed', (tester) async {
    expect(const KlaroApp(), isA<StatelessWidget>());
  });
}
