import 'package:flutter/material.dart';
import 'pages/sample_list_page.dart';
import 'theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'database/app_database.dart';
import 'database/sample_event_local_data_source.dart';
import 'remote/sample_event_remote_data_source.dart';
import 'repositories/sample_event_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final database = AppDatabase();
  final localDataSource = SampleEventLocalDataSource(database);
  final remoteDataSource = SampleEventRemoteDataSource(
    FirebaseFirestore.instance,
  );
  final repository = SampleEventRepository(
    local: localDataSource,
    remote: remoteDataSource,
  );

  runApp(SampleTrackApp(sampleEventRepository: repository));
}

class SampleTrackApp extends StatelessWidget {

  final SampleEventRepository sampleEventRepository;

  const SampleTrackApp({
    super.key,
    required this.sampleEventRepository,
    });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SampleTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SampleListPage(
        sampleEventRepository : sampleEventRepository
      ),
    );
  }
}
