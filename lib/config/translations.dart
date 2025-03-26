class ColorTranslations {
  static const Map<String, String> colorNames = {
    'RED': 'Đỏ',
    'YELLOW': 'Vàng',
    'BLUE': 'Xanh dương',
    'GREEN': 'Xanh lá',
    'PURPLE': 'Tím',
    'BROWN': 'Nâu',
    'GRAY': 'Xám',
    'PINK': 'Hồng',
    'ORANGE': 'Cam',
    'BLACK': 'Đen',
    'WHITE': 'Trắng',
  };

  static String getColorName(String englishName) {
    return colorNames[englishName.toUpperCase()] ?? englishName;
  }

  static String getEnglishName(String vietnameseName) {
    return colorNames.entries
        .firstWhere(
          (entry) => entry.value == vietnameseName,
          orElse: () => MapEntry(vietnameseName, vietnameseName),
        )
        .key;
  }
}

class SizeTranslations {
  static const Map<String, String> sizeNames = {
    'S': 'Nhỏ (S)',
    'M': 'Vừa (M)',
    'L': 'Lớn (L)',
    'XL': 'Rất lớn (XL)',
    'XXL': 'Cực lớn (XXL)',
  };

  static String getSizeName(String englishName) {
    return sizeNames[englishName] ?? englishName;
  }

  static String getEnglishName(String vietnameseName) {
    return sizeNames.entries
        .firstWhere(
          (entry) => entry.value == vietnameseName,
          orElse: () => MapEntry(vietnameseName, vietnameseName),
        )
        .key;
  }
}