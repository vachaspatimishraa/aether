import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/unit_converter_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/glowing_badge.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  int _categoryIndex = 0;
  late UnitDefinition _fromUnit;
  late UnitDefinition _toUnit;
  double _inputValue = 1.0;
  final TextEditingController _inputController = TextEditingController(text: '1');

  UnitCategory get _currentCategory => UnitConverterService.categories[_categoryIndex];

  @override
  void initState() {
    super.initState();
    _fromUnit = _currentCategory.units[0];
    _toUnit = _currentCategory.units.length > 1 ? _currentCategory.units[1] : _currentCategory.units[0];
  }

  void _onCategoryChanged(int idx) {
    setState(() {
      _categoryIndex = idx;
      _fromUnit = _currentCategory.units[0];
      _toUnit = _currentCategory.units.length > 1 ? _currentCategory.units[1] : _currentCategory.units[0];
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
  }

  String _format(double d) {
    if (d.abs() < 1e-6 && d != 0) return d.toStringAsExponential(4);
    if (d.abs() >= 1e8) return d.toStringAsExponential(4);
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final convertedValue = UnitConverterService.convert(
      value: _inputValue,
      from: _fromUnit,
      to: _toUnit,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(UnitConverterService.categories.length, (i) {
                final cat = UnitConverterService.categories[i];
                final isSelected = _categoryIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Text(cat.iconSymbol, style: const TextStyle(fontSize: 14)),
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) _onCategoryChanged(i);
                    },
                    selectedColor: LuxuryTheme.emeraldDark,
                    backgroundColor: LuxuryTheme.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? LuxuryTheme.emeraldBright : LuxuryTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? LuxuryTheme.emeraldPrimary : LuxuryTheme.borderMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),

          // Main conversion card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: LuxuryTheme.surfaceCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: LuxuryTheme.borderGlowing, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: LuxuryTheme.emeraldSubtle,
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              children: [
                // FROM Unit Input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _inputController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: LuxuryTheme.textBright,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          labelText: 'From Value',
                          labelStyle: TextStyle(color: LuxuryTheme.emeraldPrimary, fontSize: 13),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: LuxuryTheme.surfaceDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: LuxuryTheme.borderMuted),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: LuxuryTheme.emeraldPrimary, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _inputValue = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxuryTheme.borderMuted),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UnitDefinition>(
                            value: _fromUnit,
                            isExpanded: true,
                            dropdownColor: LuxuryTheme.surfaceCardElevated,
                            style: TextStyle(
                              color: LuxuryTheme.emeraldBright,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: _currentCategory.units.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text('${u.symbol} (${u.name})', overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _fromUnit = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Swap units button with gold glow
                IconButton(
                  icon: Icon(Icons.swap_vert_circle, size: 34, color: LuxuryTheme.goldPrimary),
                  tooltip: 'Swap Units',
                  onPressed: _swapUnits,
                ),

                const SizedBox(height: 12),

                // TO Unit Output
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxuryTheme.goldWarm, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _format(convertedValue),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: LuxuryTheme.goldPrimary,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, size: 16, color: LuxuryTheme.textMuted),
                              tooltip: 'Copy converted value',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _format(convertedValue)));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Converted value copied!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuxuryTheme.borderMuted),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UnitDefinition>(
                            value: _toUnit,
                            isExpanded: true,
                            dropdownColor: LuxuryTheme.surfaceCardElevated,
                            style: TextStyle(
                              color: LuxuryTheme.goldPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: _currentCategory.units.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text('${u.symbol} (${u.name})', overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _toUnit = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Simultaneous multi-unit conversion breakdown table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LuxuryTheme.surfaceDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: LuxuryTheme.borderMuted),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart_outlined, color: LuxuryTheme.emeraldBright, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'All ${_currentCategory.name} Equivalents for ${_format(_inputValue)} ${_fromUnit.symbol}:',
                      style: TextStyle(
                        color: LuxuryTheme.emeraldBright,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._currentCategory.units.map((unit) {
                  final converted = UnitConverterService.convert(
                    value: _inputValue,
                    from: _fromUnit,
                    to: unit,
                  );
                  final isCurrentTo = unit.name == _toUnit.name;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            unit.symbol,
                            style: TextStyle(
                              color: isCurrentTo ? LuxuryTheme.goldPrimary : LuxuryTheme.textMuted,
                              fontWeight: isCurrentTo ? FontWeight.bold : FontWeight.w500,
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            unit.name,
                            style: TextStyle(
                              color: isCurrentTo ? LuxuryTheme.textBright : LuxuryTheme.textSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          _format(converted),
                          style: TextStyle(
                            color: isCurrentTo ? LuxuryTheme.emeraldBright : LuxuryTheme.textBright,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

