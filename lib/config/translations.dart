import 'package:flutter/material.dart';

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

class OrderStatusTranslations {
  static const Map<String, String> statusNames = {
    'PENDING': 'Chờ xác nhận',
    'PROCESSING': 'Đang xử lý',
    'SHIPPING': 'Đang giao hàng',
    'DELIVERED': 'Đã giao hàng',
    'CANCELLED': 'Đã hủy',
    'RETURNED': 'Đã trả hàng',
  };

  static String getStatusName(String? englishName) {
    if (englishName == null) return 'Không xác định';
    return statusNames[englishName.toUpperCase()] ?? englishName;
  }

  static Color getStatusColor(String? englishName) {
    if (englishName == null) return Colors.grey;

    switch (englishName.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'SHIPPING':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'RETURNED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class PaymentStatusTranslations {
  static const Map<String, String> statusNames = {
    'PENDING': 'Chờ thanh toán',
    'SUCCESS': 'Đã thanh toán',
    'FAILED': 'Thanh toán thất bại',
  };

  static String getStatusName(String? englishName) {
    if (englishName == null) return 'Không xác định';
    return statusNames[englishName.toUpperCase()] ?? englishName;
  }

  static Color getStatusColor(String? englishName) {
    if (englishName == null) return Colors.grey;

    switch (englishName.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class DeliveryMethodTranslations {
  static const Map<String, String> methodNames = {
    'GHN': 'Giao hàng nhanh (GHN)',
    'EXPRESS': 'Giao hàng hỏa tốc',
  };

  static String getMethodName(String? englishName) {
    if (englishName == null) return 'Không xác định';
    return methodNames[englishName.toUpperCase()] ?? englishName;
  }
}

class PaymentMethodTranslations {
  static const Map<String, String> methodNames = {
    'COD': 'Thanh toán khi nhận hàng (COD)',
    'VNPAY': 'Thanh toán qua VNPAY',
  };

  static String getMethodName(String? englishName) {
    if (englishName == null) return 'Không xác định';
    return methodNames[englishName.toUpperCase()] ?? englishName;
  }
}
