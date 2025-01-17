import 'package:flutter/material.dart';
import 'package:gigaturnip/src/theme/index.dart';
import 'package:gigaturnip/src/widgets/chip_bar/index.dart';

class FilterBar extends StatefulWidget {
  final String title;
  final String value;
  final Map<String, Map<String, dynamic>?> filters;
  final List<String> names;
  final void Function(Map<String, dynamic>? value) onChanged;

  const FilterBar({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.filters,
    required this.names,
  }) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late String _activeFilter = widget.value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final keys = widget.filters.keys.toList();
    final values = widget.filters.values.toList();

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: theme.isLight ? theme.neutral30 : theme.neutral90,
            ),
          ),
          const SizedBox(height: 15),
          FixedChipBar(
            children: [
              for (var i = 0; i < widget.filters.length; i++)
                DefaultChip(
                  label: widget.names[i],
                  active: keys[i] == _activeFilter,
                  onPressed: () {
                    setState(() {
                      _activeFilter = keys[i];
                    });
                    widget.onChanged(values[i]);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}