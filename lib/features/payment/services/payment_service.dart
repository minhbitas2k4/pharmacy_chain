class PaymentService {
  Future<void> pay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
