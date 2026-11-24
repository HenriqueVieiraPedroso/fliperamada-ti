/// Aceita 22.00, 22,00 e 1.234,56. Entradas inválidas não viram zero.
double? parseMoney(String input) {
  var value = input.trim().replaceAll('R\$', '').replaceAll(RegExp(r'\s'), '');
  if (value.isEmpty) return null;
  if (value.contains(',')) {
    if (!RegExp(r'^-?(?:\d+|\d{1,3}(?:\.\d{3})+),\d{1,2}$').hasMatch(value)) {
      return null;
    }
    value = value.replaceAll('.', '').replaceAll(',', '.');
  } else if (!RegExp(r'^-?\d+(?:\.\d{1,2})?$').hasMatch(value)) {
    return null;
  }
  final parsed = double.tryParse(value);
  return parsed != null && parsed.isFinite ? parsed : null;
}
