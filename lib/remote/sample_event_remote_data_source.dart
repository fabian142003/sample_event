import '../models/sample_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Punto de inicio para la fuente remota.
///
/// La shell no incluye Firebase ni Cloud Firestore como dependencias.
class SampleEventRemoteDataSource {
  final FirebaseFirestore firestore;

  SampleEventRemoteDataSource(this.firestore);

  //obtenemos la tabla
  CollectionReference<Map<String, dynamic>> get _events =>
      firestore.collection('sample_events');

  Future<void> saveEvent(SampleEvent event) async {
    final json = event.toJson();
    json['createdAt'] = Timestamp.fromDate(event.createdAt);
    await _events.doc(event.id).set(json);
  }

  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final snapshot = await _events.where('sampleId', isEqualTo: sampleId).get(const GetOptions(source: Source.server));

    return snapshot.docs.map((document) {
      final json = document.data();
      final timestamp = json['createdAt'] as Timestamp;

      return SampleEvent.fromJson({
        ...json,
        'createdAt': timestamp.toDate().toIso8601String(),
      });
    }).toList();
  }
}
