import 'package:flutter/widgets.dart';

import '../models/sample_event.dart';
import 'app_database.dart';

class SampleEventLocalDataSource {


  final AppDatabase db;

  SampleEventLocalDataSource(this.db);

  SampleEvent _toDomain(SampleEventRow row) {
    return SampleEvent(
      id: row.id,
      sampleId: row.sampleId,
      type: row.type,
      createdAt: row.createdAt,
    );
  }

  Future<void> saveEvent(SampleEvent event) async {

    await db.into(db.sampleEvents).insertOnConflictUpdate(
          SampleEventsCompanion.insert(
            id: event.id,
            sampleId: event.sampleId,
            type: event.type,
            createdAt: event.createdAt,
          ),
        );

      debugPrint('Se guarda local evento: ${event.type} de muestraId: ${event.sampleId}');

  }

  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {

    final rows = await (db.select(db.sampleEvents)
          ..where((event) => event.sampleId.equals(sampleId))).get();

    List<SampleEvent> events =  rows.map(_toDomain).toList();
    return events;
  }

  //reemplaza eventos con los obtenidos en firebase -> para sincronizar
  Future<void> replaceEventsForSample( String sampleId, List<SampleEvent> events) async {
    await db.transaction(() async {
      await (db.delete(db.sampleEvents)
            ..where((event) => event.sampleId.equals(sampleId)))
          .go();

      for (final event in events) {
        await db.into(db.sampleEvents).insertOnConflictUpdate(
              SampleEventsCompanion.insert(
                id: event.id,
                sampleId: event.sampleId,
                type: event.type,
                createdAt: event.createdAt,
              ),
            );
      }

    }
    );
  }
}