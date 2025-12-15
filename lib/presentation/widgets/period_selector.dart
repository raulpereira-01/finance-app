import 'package:flutter/material.dart';

import '../../domain/entities/selected_period.dart';

class PeriodSelector extends StatelessWidget {
  final SelectedPeriod selectedPeriod;
  final ValueChanged<SelectedPeriod> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => onPeriodChanged(selectedPeriod.previousMonth()),
        ),
        Text(
          selectedPeriod.formattedLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => onPeriodChanged(selectedPeriod.nextMonth()),
        ),
      ],
    );
  }
}
