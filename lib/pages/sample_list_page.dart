import 'package:flutter/material.dart';
import 'package:sample_track_shell/repositories/sample_event_repository.dart';

import '../data/sample_seed.dart';
import '../models/sample.dart';
import '../widgets/sample_card.dart';
import 'sample_detail_page.dart';

class SampleListPage extends StatelessWidget {

 final SampleEventRepository sampleEventRepository;

  const SampleListPage({
    super.key,
    required this.sampleEventRepository,
  });

  void _openDetail(BuildContext context, Sample sample) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SampleDetailPage(sample: sample, sampleEventRepository : sampleEventRepository),
      ),
    );
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
            return SampleCard(
              sample: sample,
              onTap: () => _openDetail(context, sample),
            );
          },
        ),
      ),
    );
  }
}
