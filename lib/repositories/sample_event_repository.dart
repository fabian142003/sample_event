import 'package:flutter/foundation.dart';
import 'package:sample_track_shell/database/sample_event_local_data_source.dart';
import 'package:sample_track_shell/remote/sample_event_remote_data_source.dart';

import '../models/sample_event.dart';

//Instancia devuelve eventos local/remoto 
class SampleEventsLoadResult {
  const SampleEventsLoadResult({
    required this.events,
    required this.usedLocalCache,
  });

  final List<SampleEvent> events;
  final bool usedLocalCache;
}

/// Punto de inicio para coordinar las fuentes de datos del examen.
class SampleEventRepository {

  final SampleEventLocalDataSource local;
  final SampleEventRemoteDataSource remote;

  SampleEventRepository({
    required this.local,
    required this.remote,
  });

  Future<SampleEventsLoadResult> getEventsForSample(String sampleId) async {
    late final List<SampleEvent> events;

    try {
      events = await remote.getEventsForSample(sampleId);
      
    } catch (error) {
      debugPrint('Fallo obtener remoto: $error');

      final cachedEvents = await local.getEventsForSample(sampleId);
      debugPrint('Eventos obtenidos desde el cache local.');

      return SampleEventsLoadResult(
        events: cachedEvents,
        usedLocalCache: true,
      );
    }

    await local.replaceEventsForSample(sampleId, events);
      debugPrint('Eventos obtenidos desde Firestore');


      return SampleEventsLoadResult(
        events: events,
        usedLocalCache: false,
      );

  }

  Future<void> registerEvent(SampleEvent event) async {
    await remote.saveEvent(event);
    await local.saveEvent(event);
  }

}
