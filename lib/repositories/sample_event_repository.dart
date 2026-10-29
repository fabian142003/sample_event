import 'package:flutter/foundation.dart';
import 'package:sample_track_shell/database/sample_event_local_data_source.dart';
import 'package:sample_track_shell/models/sample_status.dart';
import 'package:sample_track_shell/remote/sample_event_remote_data_source.dart';

import '../models/sample_event.dart';


class EventException implements Exception {
  const EventException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

  //unicamente permite registrar el evento de una muestra con el estado siguiente
  Future<void> registerNextEvent(String sampleId) async {
    final loadResult = await getEventsForSample(sampleId);
    final events = loadResult.events;
    final currentStatus = SampleStatus.fromEvents(events);
    final nextStatus = SampleStatus.nextForEvents(events);
    
    if (nextStatus == null) {
      if (events.isNotEmpty && currentStatus == null) {
        throw const EventException(
          "error registrar evento: el historial tiene el ultimo evento con estado desconocido"
          );
        }

      throw const EventException(
        "error registrar evento: la muestra ya completo todos los estados"
      );
    }

    final event = SampleEvent(
      id: remote.createEventId(),
      sampleId: sampleId,
      type: nextStatus.eventType,
      createdAt: DateTime.now(),
    );



    await remote.saveEvent(event);
    await local.saveEvent(event);
  }

}
