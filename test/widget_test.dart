import 'package:flutter_test/flutter_test.dart';
import 'package:poss_poss/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PossPossApp());
    expect(find.text('POSS POSS'), findsOneWidget);
    expect(find.text('开始拍照'), findsOneWidget);
    expect(find.text('查看历史'), findsOneWidget);
  });
}
