import 'package:flutter_test/flutter_test.dart';
//import 'package:sample_track_shell/main.dart';

void main() {
  testWidgets('SampleTrack muestra el catalogo inicial', (tester) async {
    //await tester.pumpWidget(const SampleTrackApp());

    expect(find.text('SampleTrack'), findsOneWidget);
    expect(find.text('M-1001'), findsOneWidget);
    expect(find.text('M-1005'), findsOneWidget);
  });
}
