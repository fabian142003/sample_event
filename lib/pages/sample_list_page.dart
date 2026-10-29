import 'package:flutter/material.dart';
import 'package:sample_track_shell/models/sample_status.dart';
import 'package:sample_track_shell/repositories/sample_event_repository.dart';

import '../data/sample_seed.dart';
import '../models/sample.dart';
import '../widgets/sample_card.dart';
import 'sample_detail_page.dart';

class SampleListPage extends StatefulWidget {
  final SampleEventRepository sampleEventRepository;

  const SampleListPage({
    super.key,
    required this.sampleEventRepository,
  });

  @override
  State<SampleListPage> createState() => _SampleListPageState();
}

class _SampleListPageState extends State<SampleListPage> {
  //traer eventos de una muestra
  late Map<String, Future<SampleEventsLoadResult>> _eventsBySample;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _eventsBySample = {};

    for (final sample in sampleSeed) {
      _eventsBySample[sample.id] =
          widget.sampleEventRepository.getEventsForSample(sample.id);
    }
  }

  Future<void> _openDetail(BuildContext context, Sample sample) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SampleDetailPage(
          sample: sample,
          sampleEventRepository: widget.sampleEventRepository,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _eventsBySample[sample.id]  = widget.sampleEventRepository.getEventsForSample(sample.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.biotech_outlined),
            SizedBox(width: 10),
            Text('SampleTrack'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sampleSeed.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {

            final sample = sampleSeed[index];
            final eventsFuture = _eventsBySample[sample.id]!;

            return FutureBuilder<SampleEventsLoadResult>(
              future: eventsFuture,
              builder: (context, snapshot) {
                String statusLabel;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  statusLabel = 'Cargando...';
                } else if (snapshot.hasError) {
                  statusLabel = 'Error al cargar';
                } else if (snapshot.hasData) {
                  statusLabel = SampleStatus.labelForEvents(
                    snapshot.data!.events,
                  );
                } else {
                  statusLabel = 'Sin eventos';
                }

                return SampleCard(
                  sample: sample,
                  statusLabel: statusLabel,
                  onTap: () => _openDetail(context, sample),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
