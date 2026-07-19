class PharmacistDrug {
  const PharmacistDrug({
    required this.productId,
    required this.inventoryId,
    required this.name,
    required this.activeIngredient,
    required this.dosage,
    required this.indications,
    required this.shelfLocation,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.price,
    required this.prescriptionRequired,
  });

  final String productId;
  final String inventoryId;
  final String name;
  final String activeIngredient;
  final String dosage;
  final String indications;
  final String shelfLocation;
  final String batchNumber;
  final DateTime? expiryDate;
  final int quantity;
  final double price;
  final bool prescriptionRequired;

  bool get isOutOfStock => quantity <= 0;

  bool get isExpired {
    final DateTime? date = expiryDate;
    if (date == null) return false;
    final DateTime today = DateTime.now();
    final DateTime normalizedToday = DateTime(today.year, today.month, today.day);
    return date.isBefore(normalizedToday);
  }

  bool get canSell => !isOutOfStock && !isExpired;
}

class PharmacistCartItem {
  const PharmacistCartItem({
    required this.productId,
    required this.inventoryId,
    required this.productName,
    required this.activeIngredient,
    required this.batchNumber,
    required this.unitPrice,
    required this.quantity,
    required this.availableQuantity,
  });

  final String productId;
  final String inventoryId;
  final String productName;
  final String activeIngredient;
  final String batchNumber;
  final double unitPrice;
  final int quantity;
  final int availableQuantity;

  double get lineTotal => unitPrice * quantity;

  PharmacistCartItem copyWith({int? quantity}) {
    return PharmacistCartItem(
      productId: productId,
      inventoryId: inventoryId,
      productName: productName,
      activeIngredient: activeIngredient,
      batchNumber: batchNumber,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity,
    );
  }

  Map<String, dynamic> toEmbeddedMap() {
    return <String, dynamic>{
      'product_id': productId,
      'product_name': productName,
      'inventory_id': inventoryId,
      'active_ingredient': activeIngredient,
      'batch_number': batchNumber,
      'quantity': quantity.toString(),
      'price': unitPrice.toStringAsFixed(0),
      'line_total': lineTotal.toStringAsFixed(0),
    };
  }
}

class PrescriptionLine {
  const PrescriptionLine({
    required this.productId,
    required this.inventoryId,
    required this.productName,
    required this.activeIngredient,
    required this.batchNumber,
    required this.unitPrice,
    required this.availableQuantity,
    required this.dosage,
    required this.frequency,
    required this.quantity,
    this.duration = '',
    this.instructions = '',
  });

  final String productId;
  final String inventoryId;
  final String productName;
  final String activeIngredient;
  final String batchNumber;
  final double unitPrice;
  final int availableQuantity;
  final String dosage;
  final String frequency;
  final int quantity;
  final String duration;
  final String instructions;

  factory PrescriptionLine.fromDrug(PharmacistDrug drug) {
    return PrescriptionLine(
      productId: drug.productId,
      inventoryId: drug.inventoryId,
      productName: drug.name,
      activeIngredient: drug.activeIngredient,
      batchNumber: drug.batchNumber,
      unitPrice: drug.price,
      availableQuantity: drug.quantity,
      dosage: drug.dosage,
      frequency: 'Theo chỉ định',
      quantity: 1,
      instructions: drug.indications,
    );
  }

  PrescriptionLine copyWith({
    String? dosage,
    String? frequency,
    int? quantity,
    String? duration,
    String? instructions,
  }) {
    return PrescriptionLine(
      productId: productId,
      inventoryId: inventoryId,
      productName: productName,
      activeIngredient: activeIngredient,
      batchNumber: batchNumber,
      unitPrice: unitPrice,
      availableQuantity: availableQuantity,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      quantity: quantity ?? this.quantity,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  PharmacistCartItem toCartItem() {
    return PharmacistCartItem(
      productId: productId,
      inventoryId: inventoryId,
      productName: productName,
      activeIngredient: activeIngredient,
      batchNumber: batchNumber,
      unitPrice: unitPrice,
      quantity: quantity,
      availableQuantity: availableQuantity,
    );
  }
}

class DrugInteractionWarning {
  const DrugInteractionWarning({
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
    required this.message,
  });

  final String ingredientA;
  final String ingredientB;
  final String severity;
  final String message;
}

class PharmacistInvoiceLine {
  const PharmacistInvoiceLine({
    required this.productName,
    required this.batchNumber,
    required this.quantity,
    required this.unitPrice,
  });

  final String productName;
  final String batchNumber;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}

class PharmacistInvoice {
  const PharmacistInvoice({
    required this.orderId,
    required this.invoiceNumber,
    required this.branchName,
    required this.pharmacistName,
    required this.issuedAt,
    required this.paymentMethod,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.lines,
  });

  final String orderId;
  final String invoiceNumber;
  final String branchName;
  final String pharmacistName;
  final DateTime issuedAt;
  final String paymentMethod;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final List<PharmacistInvoiceLine> lines;
}
