import 'package:flutter/material.dart';



class SampleFilters extends StatelessWidget {

  const SampleFilters({
    super.key,
    required this.priorities,
    required this.allStatus,
    required this.selectedPriority,
    required this.selectedStatus,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  final List<String> priorities;
  final List<String> allStatus;

  final String? selectedPriority;
  final String? selectedStatus;

  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;
  

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [

        DropdownButtonFormField<String?>(
          initialValue: selectedPriority,
          decoration: const InputDecoration(
            labelText: 'Filtrar por prioridad',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas'),
            ),
            ...priorities.map(
              (priority) => DropdownMenuItem<String?>(
                value: priority,
                child: Text(priority),
              ),
            ),
          ],
          onChanged: onPriorityChanged,
        ),

        const SizedBox(height: 12),
        
        DropdownButtonFormField<String?>(
          initialValue: selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Filtrar por estado',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos'),
            ),
            ...allStatus.map(
              (status) => DropdownMenuItem<String?>(
                value: status,
                child: Text(status),
              ),
            ),
          ],
          onChanged: onStatusChanged,
        ),
      ],
    );
  }
}
