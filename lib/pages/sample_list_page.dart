import 'package:flutter/material.dart';
import 'package:sample_track_shell/models/sample_event.dart';
import 'package:sample_track_shell/models/sample_status.dart';
import 'package:sample_track_shell/repositories/sample_event_repository.dart';
import 'package:sample_track_shell/widgets/sample_filters.dart';

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
  //late Map<String, Future<SampleEventsLoadResult>> _eventsBySample;
  late Future<List<SampleListItem>> _samplesFuture;

  String? _selectedPriority;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _samplesFuture = _loadSamples();
  }

  Future<List<SampleListItem>> _loadSamples() async {
    final items = <SampleListItem>[];

    for (final sample in sampleSeed) {
      final result =
          await widget.sampleEventRepository.getEventsForSample(sample.id);

      items.add(SampleListItem(sample: sample, events: result.events));
    }
    return items;
  }

  Future<void> _openDetail(Sample sample) async {
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
      _samplesFuture = _loadSamples();
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
        child: FutureBuilder(
            future: _samplesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('No se pudieron cargar las muestras.'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No se recibieron datos.'));
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return const Center(
                    child: Text('No hay muestras registradas.'));
              }

              final priorities =
                  items.map((item) => item.sample.priority).toSet().toList();

              final allStatus = [
                'Sin eventos',
                ...SampleStatus.values.map((status) => status.label),
              ];

              //filtrar muestra por prioridad y estado de ult evento
              final visibleItems = items.where(
                (item) {
                  final matchesPriority = _selectedPriority == null ||
                      _selectedPriority == item.sample.priority;

                  final matchesStatus = _selectedStatus == null ||
                      _selectedStatus == item.statusLabel;

                  return matchesPriority && matchesStatus;
                },
              ).toList();

              return Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),

                  child: SampleFilters(
                    priorities: priorities,
                    allStatus: allStatus,
                    selectedPriority: _selectedPriority,
                    selectedStatus: _selectedStatus,
                    onPriorityChanged: (priority) {
                      setState(() => _selectedPriority = priority);
                    },
                    onStatusChanged: (status) {
                      setState(() => _selectedStatus = status);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Muestras visibles: ${visibleItems.length}'),
                  ),
                ),

                Expanded(
                  child:visibleItems.isEmpty 
                  ? (Center(child: Text('No hay muestras que cumplan con los filtros'),))
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];

                      return SampleCard(
                        sample: item.sample,
                        statusLabel: item.statusLabel,
                        onTap: () => _openDetail(item.sample),
                      );
                    },
                  ),
                ),
              ]);
            }       
          ),
      ),
    );
  }
}

//instacia muestra y eventos con su id
class SampleListItem {
  const SampleListItem({
    required this.sample,
    required this.events,
  });

  final Sample sample;
  final List<SampleEvent> events;

  String get statusLabel => SampleStatus.labelForEvents(events);
}
