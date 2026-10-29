import 'package:drift/drift.dart';

@DataClassName('SampleEventRow')
class SampleEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sampleId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

}