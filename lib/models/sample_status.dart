


import 'package:sample_track_shell/models/sample_event.dart';

enum SampleStatus {


  received('RECEIVED', 'Recibida'),
  prepared('PREPARED', 'Preparada'),
  inAnalysis('IN_ANALYSIS', 'En analisis'),
  validated('VALIDATED', 'Validada'),
  archived('ARCHIVED', 'Archivada');

  const SampleStatus(this.eventType, this.label);

  final String eventType;
  final String label;

  static SampleStatus? fromEventType(String type) {
    for (final status in values) {
      if (status.eventType == type) {
        return status;
      }
    }
    return null;
  }

  static SampleStatus? fromEvents(List<SampleEvent> events) {

    SampleEvent? latestEvent;

    for(final event in events) {
      if(latestEvent == null || event.createdAt.isAfter(latestEvent.createdAt)) {
        latestEvent = event;
      }
    }

    if (latestEvent == null) return null;

    return fromEventType(latestEvent.type);

  }

  //mostrar estado del ultimo evento
  static String labelForEvents(List<SampleEvent> events) {
  if (events.isEmpty) {
    return 'Sin eventos';
  }

  return fromEvents(events)?.label ?? 'Estado desconocido';
  }

  //obtiene el siguiente estado de muestra,en la  lista del enum
  SampleStatus? get next {
    if(index == values.length - 1) {
      return null;
    }

    return values[index +1];
  }

  //obtiene del ultimo estao de events -> el siguiente estado de values propiedad evento
  static SampleStatus? nextForEvents(List<SampleEvent> events) {
    if(events.isEmpty) {
      return SampleStatus.received;
    }

    SampleStatus? lastStatus = fromEvents(events);
    return lastStatus?.next;
  }
}