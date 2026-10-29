import 'package:flutter/material.dart';
import 'package:sample_track_shell/models/sample_status.dart';
import 'package:sample_track_shell/repositories/sample_event_repository.dart';

import '../models/sample.dart';

class SampleDetailPage extends StatefulWidget {
  const SampleDetailPage({
    super.key,
    required this.sample,
    required this.sampleEventRepository,
  });

  final Sample sample;
  final SampleEventRepository sampleEventRepository;

  @override
  State<SampleDetailPage> createState() => _SampleDetailPageState();
}

class _SampleDetailPageState extends State<SampleDetailPage> {
  late Future<SampleEventsLoadResult> _eventsFuture;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _eventsFuture =
        widget.sampleEventRepository.getEventsForSample(widget.sample.id);
  }

  Future<void> _registerNextEvent() async {
    if (_isRegistering) return;

    try {
      setState(() => _isRegistering = true);
      await widget.sampleEventRepository.registerNextEvent(widget.sample.id);

      if (!mounted) return;

      setState(() {
        _eventsFuture =
            widget.sampleEventRepository.getEventsForSample(widget.sample.id);
        _isRegistering = false;
      });
    } catch (error) {
      debugPrint('Error: $error');

      if (!mounted) return;

      setState(() => _isRegistering = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo registrar el evento.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.sample.id)),
        body: FutureBuilder<SampleEventsLoadResult>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                      'No se pudieron cargar los eventos de esta muestra.'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('No se recibieron datos para esta muestra.'),
                );
              }

              //events de sample ordenados por fecha
              final result = snapshot.data!;

              final events = result.events.toList();
              events.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              final statusLabel = SampleStatus.labelForEvents(events);

              //estado mas reciente y siguiente, para habilitar o no boton de registro
              final currentStatus = SampleStatus.fromEvents(events);
              final nextStatus = SampleStatus.nextForEvents(events);

              final unavailableStatusLabel =
                  events.isNotEmpty && currentStatus == SampleStatus.archived
                      ? 'Ciclo completado'
                      : 'Estado no reconocido';

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SampleHeader(
                      sample: widget.sample, statusLabel: statusLabel),
                  if (result.usedLocalCache)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                          'Cache: Muestras cargadas desde el local, no hay conexion con firebbase '),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    'Historial de procesamiento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  if (events.isEmpty)
                    const _EmptyHistory()
                  else
                    ...events.map(
                      (event) => ListTile(
                        title: Text(event.type),
                        subtitle: Text(event.createdAt.toLocal().toString()),
                      ),
                    ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _isRegistering || nextStatus == null
                        ? null
                        : _registerNextEvent,
                    child: _isRegistering
                        ? const CircularProgressIndicator()
                        : Text(
                            nextStatus == null
                                ? unavailableStatusLabel
                                : 'Registrar evento siguiente estado -> ${nextStatus.label}',
                          ),
                  ),
                ],
              );
            }));
  }
}

class _SampleHeader extends StatelessWidget {
  const _SampleHeader({required this.sample, required this.statusLabel});

  final Sample sample;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.science_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sample.id,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Chip(label: Text(statusLabel)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _InfoField(label: 'Tipo', value: sample.type),
                _InfoField(label: 'Origen', value: sample.origin),
                _InfoField(label: 'Prioridad', value: sample.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Esta muestra aun no tiene eventos de procesamiento.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
