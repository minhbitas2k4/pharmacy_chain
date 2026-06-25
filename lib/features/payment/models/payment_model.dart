enum PaymentMethod { cash, vietqr, card, mixed }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.vietqr:
        return 'VietQR';
      case PaymentMethod.card:
        return 'Thẻ';
      case PaymentMethod.mixed:
        return 'Kết hợp';
    }
  }
}
