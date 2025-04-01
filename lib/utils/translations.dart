/// Translations for payment methods
class PaymentMethodTranslations {
  static String getMethodName(String? methodCode) {
    if (methodCode == null) return '';

    switch (methodCode.toUpperCase()) {
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case 'VNPAY':
        return 'Thanh toán qua VNPay';
      default:
        return methodCode;
    }
  }
}

/// Translations for payment status
class PaymentStatusTranslations {
  static String getStatusName(String? statusCode) {
    if (statusCode == null) return '';

    switch (statusCode.toUpperCase()) {
      case 'SUCCESS':
        return 'Đã thanh toán';
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'FAILED':
        return 'Thanh toán thất bại';
      default:
        return statusCode;
    }
  }
}

/// Translations for order status
class OrderStatusTranslations {
  static String getStatusName(String? statusCode) {
    if (statusCode == null) return '';

    switch (statusCode.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'PROCESSING':
        return 'Đang chuẩn bị';
      case 'SHIPPING':
        return 'Đang giao hàng';
      case 'DELIVERED':
        return 'Đã giao hàng';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'RETURNED':
        return 'Đã trả hàng';
      default:
        return statusCode;
    }
  }
}

/// Translations for delivery methods
class DeliveryMethodTranslations {
  static String getMethodName(String? methodCode) {
    if (methodCode == null) return '';

    switch (methodCode.toUpperCase()) {
      case 'GHN':
        return 'Giao hàng nhanh (GHN)';
      case 'EXPRESS':
        return 'Giao hàng hỏa tốc (EXPRESS)';
      default:
        return methodCode;
    }
  }
}
