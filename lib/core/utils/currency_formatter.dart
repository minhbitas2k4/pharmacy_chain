class CurrencyFormatter {
  static String format(num value) {
    final String raw = value.toStringAsFixed(0);
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < raw.length; index++) {
      final int remaining = raw.length - index;
      buffer.write(raw[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()} đ';
  }
}
