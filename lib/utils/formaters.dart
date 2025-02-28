String formatNumber(num value) {
  if (value >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(1)}B';
  } else if (value >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(1)}M';
  } else if (value >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(1)}K';
  } else {
    return value.toString(); // Giá trị gốc
  }
}
