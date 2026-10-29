import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'sample_events_table.dart';
part 'app_database.g.dart';


/// Punto de inicio para la persistencia local del examen.
///
/// La shell no incluye Drift como dependencia. Este archivo compila sin Drift
/// para que la aplicacion inicial pueda ejecutarse. Durante el examen se debe
/// transformar esta clase en la base de datos requerida por el enunciado.
/// 

@DriftDatabase(tables: [SampleEvents])
class AppDatabase extends _$AppDatabase {
  // se agrega la configuracion de persistencia local requerida.
  AppDatabase() : super(_openConnection());


  @override
  int get schemaVersion => 1;

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sampletrack.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
