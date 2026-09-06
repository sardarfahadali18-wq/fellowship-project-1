import 'package:flutter/material.dart';

/// Large-button numeric keypad for entering a rupee amount.
///
/// Keeps its own text buffer and reports the current value via [onChanged]
/// on every keystroke; callers don't need a [TextEditingController].
class NumericKeypad extends StatefulWidget {
  const NumericKeypad({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  String _value = '';

  static const _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '.', '0', '⌫',
  ];

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_value.isNotEmpty) {
          _value = _value.substring(0, _value.length - 1);
        }
      } else if (key == '.') {
        if (!_value.contains('.')) {
          _value = _value.isEmpty ? '0.' : '$_value.';
        }
      } else {
        _value += key;
      }
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: _keys.map((key) {
        final isBackspace = key == '⌫';
        return Material(
          color: isBackspace
              ? colorScheme.errorContainer
              : colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onKeyTap(key),
            child: Center(
              child: Text(
                key,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isBackspace
                          ? colorScheme.onErrorContainer
                          : colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
