class UnitCategory {
  final String name;
  final String iconSymbol;
  final List<UnitDefinition> units;

  const UnitCategory({
    required this.name,
    required this.iconSymbol,
    required this.units,
  });
}

class UnitDefinition {
  final String name;
  final String symbol;
  final double toBaseFactor;
  final double offset; // Used for temperature (e.g. Celsius to Kelvin)

  const UnitDefinition({
    required this.name,
    required this.symbol,
    required this.toBaseFactor,
    this.offset = 0.0,
  });

  double toBase(double value) => (value + offset) * toBaseFactor;
  double fromBase(double baseValue) => (baseValue / toBaseFactor) - offset;
}

class UnitConverterService {
  static final List<UnitCategory> categories = [
    const UnitCategory(
      name: 'Length',
      iconSymbol: '📏',
      units: [
        UnitDefinition(name: 'Meters', symbol: 'm', toBaseFactor: 1.0),
        UnitDefinition(name: 'Kilometers', symbol: 'km', toBaseFactor: 1000.0),
        UnitDefinition(name: 'Centimeters', symbol: 'cm', toBaseFactor: 0.01),
        UnitDefinition(name: 'Millimeters', symbol: 'mm', toBaseFactor: 0.001),
        UnitDefinition(name: 'Miles', symbol: 'mi', toBaseFactor: 1609.344),
        UnitDefinition(name: 'Yards', symbol: 'yd', toBaseFactor: 0.9144),
        UnitDefinition(name: 'Feet', symbol: 'ft', toBaseFactor: 0.3048),
        UnitDefinition(name: 'Inches', symbol: 'in', toBaseFactor: 0.0254),
        UnitDefinition(name: 'Nautical Miles', symbol: 'NM', toBaseFactor: 1852.0),
      ],
    ),
    const UnitCategory(
      name: 'Mass & Weight',
      iconSymbol: '⚖️',
      units: [
        UnitDefinition(name: 'Kilograms', symbol: 'kg', toBaseFactor: 1.0),
        UnitDefinition(name: 'Grams', symbol: 'g', toBaseFactor: 0.001),
        UnitDefinition(name: 'Milligrams', symbol: 'mg', toBaseFactor: 1e-6),
        UnitDefinition(name: 'Metric Tons', symbol: 't', toBaseFactor: 1000.0),
        UnitDefinition(name: 'Pounds', symbol: 'lb', toBaseFactor: 0.45359237),
        UnitDefinition(name: 'Ounces', symbol: 'oz', toBaseFactor: 0.028349523),
        UnitDefinition(name: 'Stones', symbol: 'st', toBaseFactor: 6.350293),
      ],
    ),
    const UnitCategory(
      name: 'Temperature',
      iconSymbol: '🌡️',
      units: [
        UnitDefinition(name: 'Celsius', symbol: '°C', toBaseFactor: 1.0, offset: 273.15),
        UnitDefinition(name: 'Kelvin', symbol: 'K', toBaseFactor: 1.0, offset: 0.0),
        UnitDefinition(name: 'Fahrenheit', symbol: '°F', toBaseFactor: 5 / 9, offset: 459.67),
      ],
    ),
    const UnitCategory(
      name: 'Speed',
      iconSymbol: '🚀',
      units: [
        UnitDefinition(name: 'Meters / second', symbol: 'm/s', toBaseFactor: 1.0),
        UnitDefinition(name: 'Kilometers / hour', symbol: 'km/h', toBaseFactor: 1 / 3.6),
        UnitDefinition(name: 'Miles / hour', symbol: 'mph', toBaseFactor: 0.44704),
        UnitDefinition(name: 'Knots', symbol: 'kn', toBaseFactor: 0.514444),
        UnitDefinition(name: 'Feet / second', symbol: 'ft/s', toBaseFactor: 0.3048),
      ],
    ),
    const UnitCategory(
      name: 'Data Storage',
      iconSymbol: '💾',
      units: [
        UnitDefinition(name: 'Bytes', symbol: 'B', toBaseFactor: 1.0),
        UnitDefinition(name: 'Kilobytes', symbol: 'KB', toBaseFactor: 1024.0),
        UnitDefinition(name: 'Megabytes', symbol: 'MB', toBaseFactor: 1024.0 * 1024),
        UnitDefinition(name: 'Gigabytes', symbol: 'GB', toBaseFactor: 1024.0 * 1024 * 1024),
        UnitDefinition(name: 'Terabytes', symbol: 'TB', toBaseFactor: 1099511627776.0),
        UnitDefinition(name: 'Bits', symbol: 'b', toBaseFactor: 0.125),
      ],
    ),
    const UnitCategory(
      name: 'Pressure',
      iconSymbol: '🧭',
      units: [
        UnitDefinition(name: 'Pascals', symbol: 'Pa', toBaseFactor: 1.0),
        UnitDefinition(name: 'Kilopascals', symbol: 'kPa', toBaseFactor: 1000.0),
        UnitDefinition(name: 'Bar', symbol: 'bar', toBaseFactor: 100000.0),
        UnitDefinition(name: 'PSI', symbol: 'psi', toBaseFactor: 6894.757),
        UnitDefinition(name: 'Standard Atmosphere', symbol: 'atm', toBaseFactor: 101325.0),
        UnitDefinition(name: 'Torr / mmHg', symbol: 'Torr', toBaseFactor: 133.322),
      ],
    ),
    const UnitCategory(
      name: 'Energy',
      iconSymbol: '⚡',
      units: [
        UnitDefinition(name: 'Joules', symbol: 'J', toBaseFactor: 1.0),
        UnitDefinition(name: 'Kilojoules', symbol: 'kJ', toBaseFactor: 1000.0),
        UnitDefinition(name: 'Calories', symbol: 'cal', toBaseFactor: 4.184),
        UnitDefinition(name: 'Kilocalories', symbol: 'kcal', toBaseFactor: 4184.0),
        UnitDefinition(name: 'Watt-hours', symbol: 'Wh', toBaseFactor: 3600.0),
        UnitDefinition(name: 'Kilowatt-hours', symbol: 'kWh', toBaseFactor: 3600000.0),
        UnitDefinition(name: 'Electronvolts', symbol: 'eV', toBaseFactor: 1.602176634e-19),
        UnitDefinition(name: 'British Thermal Units', symbol: 'BTU', toBaseFactor: 1055.06),
      ],
    ),
    const UnitCategory(
      name: 'Time',
      iconSymbol: '⏱️',
      units: [
        UnitDefinition(name: 'Seconds', symbol: 's', toBaseFactor: 1.0),
        UnitDefinition(name: 'Minutes', symbol: 'min', toBaseFactor: 60.0),
        UnitDefinition(name: 'Hours', symbol: 'hr', toBaseFactor: 3600.0),
        UnitDefinition(name: 'Days', symbol: 'd', toBaseFactor: 86400.0),
        UnitDefinition(name: 'Weeks', symbol: 'wk', toBaseFactor: 604800.0),
        UnitDefinition(name: 'Years (365d)', symbol: 'yr', toBaseFactor: 31536000.0),
      ],
    ),
  ];

  static double convert({
    required double value,
    required UnitDefinition from,
    required UnitDefinition to,
  }) {
    if (from.name == to.name) return value;
    final base = from.toBase(value);
    return to.fromBase(base);
  }
}

