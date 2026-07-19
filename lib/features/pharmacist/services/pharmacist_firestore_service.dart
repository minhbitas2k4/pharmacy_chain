import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pharmacist_models.dart';

class PharmacistFirestoreService {
  PharmacistFirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<VietQrConfig> fetchVietQrConfig({
    required String branchId,
  }) async {
    Map<String, dynamic> branchData = <String, dynamic>{};
    try {
      final DocumentSnapshot<Map<String, dynamic>> branchSnapshot = await _db
          .collection('branches')
          .doc(branchId)
          .get();
      branchData = branchSnapshot.data() ?? <String, dynamic>{};
    } catch (_) {
      // A global configuration can still be used when branch read is denied.
    }

    final Map<String, String> globalConfig = <String, String>{};
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('system_configs')
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> document
          in snapshot.docs) {
        final Map<String, dynamic> data = document.data();

        for (final MapEntry<String, dynamic> entry in data.entries) {
          final String value = entry.value?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            globalConfig[entry.key.trim().toLowerCase()] = value;
          }
        }

        final String configKey = _readString(data, <String>[
          'config_key',
          'configKey',
          'key',
          'name',
        ]);
        final String configValue = _readString(data, <String>[
          'config_value',
          'configValue',
          'value',
        ]);
        if (configKey.isNotEmpty && configValue.isNotEmpty) {
          globalConfig[configKey.toLowerCase()] = configValue;
        }

        if (configValue.isNotEmpty) {
          globalConfig[document.id.toLowerCase()] = configValue;
        }
      }
    } catch (_) {
      // The payment screen will show a configuration message when unavailable.
    }

    String resolve(List<String> keys) {
      final String branchValue = _readString(branchData, keys);
      if (branchValue.isNotEmpty) return branchValue;

      for (final String key in keys) {
        final String? value = globalConfig[key.toLowerCase()];
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return '';
    }

    return VietQrConfig(
      bankId: resolve(<String>[
        'vietqr_bank_id',
        'vietqrBankId',
        'bank_id',
        'bankId',
        'bank_bin',
        'bankBin',
        'bank_code',
        'bankCode',
        'acq_id',
        'acqId',
      ]),
      accountNo: resolve(<String>[
        'vietqr_account_no',
        'vietqrAccountNo',
        'account_no',
        'accountNo',
        'account_number',
        'accountNumber',
        'bank_account',
        'bankAccount',
      ]),
      accountName: resolve(<String>[
        'vietqr_account_name',
        'vietqrAccountName',
        'account_name',
        'accountName',
        'bank_account_name',
        'bankAccountName',
      ]),
      template: resolve(<String>[
        'vietqr_template',
        'vietqrTemplate',
        'qr_template',
        'qrTemplate',
        'template',
      ]),
    );
  }

  Future<List<PharmacistDrug>> fetchAvailableDrugs({
    required String branchId,
  }) async {
    final List<QuerySnapshot<Map<String, dynamic>>> snapshots =
        await Future.wait<QuerySnapshot<Map<String, dynamic>>>(<Future<QuerySnapshot<Map<String, dynamic>>>>[
          _db.collection('products').get(),
          _db.collection('product_prices').get(),
          _db
              .collection('inventories')
              .where('branch_id', isEqualTo: branchId)
              .get(),
        ]);

    final QuerySnapshot<Map<String, dynamic>> productSnapshot = snapshots[0];
    final QuerySnapshot<Map<String, dynamic>> priceSnapshot = snapshots[1];
    final QuerySnapshot<Map<String, dynamic>> inventorySnapshot = snapshots[2];

    final Map<String, Map<String, dynamic>> products =
        <String, Map<String, dynamic>>{
          for (final QueryDocumentSnapshot<Map<String, dynamic>> document
              in productSnapshot.docs)
            document.id: document.data(),
        };

    final Map<String, double> globalPrices = <String, double>{};
    final Map<String, double> branchPrices = <String, double>{};

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in priceSnapshot.docs) {
      final Map<String, dynamic> data = document.data();
      final String productId = _readString(data, <String>[
        'product_id',
        'productId',
      ]);
      if (productId.isEmpty) continue;

      final double basePrice = _readDouble(data, <String>[
        'promo_price',
        'promotion_price',
        'promoPrice',
        'base_price',
        'selling_price',
        'basePrice',
      ]);
      final String priceBranchId = _readString(data, <String>[
        'branch_id',
        'branchId',
      ]);

      if (priceBranchId == branchId) {
        branchPrices[productId] = basePrice;
      } else if (priceBranchId.isEmpty) {
        globalPrices[productId] = basePrice;
      }
    }

    final List<PharmacistDrug> drugs = <PharmacistDrug>[];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> inventoryDocument
        in inventorySnapshot.docs) {
      final Map<String, dynamic> inventory = inventoryDocument.data();
      final String productId = _readString(inventory, <String>[
        'product_id',
        'productId',
      ]);
      final Map<String, dynamic>? product = products[productId];
      if (product == null) continue;

      final String productStatus = _readString(product, <String>['status']);
      if (productStatus.isNotEmpty &&
          productStatus.toLowerCase() != 'active') {
        continue;
      }

      drugs.add(
        PharmacistDrug(
          productId: productId,
          inventoryId: inventoryDocument.id,
          name: _readString(product, <String>[
            'product_name',
            'name',
            'productName',
          ]),
          activeIngredient: _readString(product, <String>[
            'active_ingredient',
            'activeIngredient',
          ]),
          dosage: _readString(product, <String>[
            'dosage',
            'strength',
            'dosage_instructions',
            'dosageInstructions',
          ]),
          indications: _readString(product, <String>[
            'indications',
            'description',
          ]),
          shelfLocation: _readString(product, <String>[
            'shift_location',
            'shelf_location',
            'shelfLocation',
          ]),
          batchNumber: _readString(inventory, <String>[
            'batch_number',
            'batchNumber',
          ]),
          expiryDate: _readDate(inventory, <String>[
            'expiry_date',
            'expiryDate',
          ]),
          quantity: _readInt(inventory, <String>['quantity']),
          price: branchPrices[productId] ?? globalPrices[productId] ?? 0,
          prescriptionRequired: _readBool(product, <String>[
            'prescription_required',
            'prescriptionRequired',
          ]),
        ),
      );
    }

    drugs.sort((PharmacistDrug a, PharmacistDrug b) {
      final int byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      if (byName != 0) return byName;
      return a.batchNumber.compareTo(b.batchNumber);
    });

    return drugs;
  }

  Future<List<DrugInteractionWarning>> checkDrugInteractions({
    required List<String> productIds,
    required List<String> activeIngredients,
  }) async {
    final Set<String> normalizedProductIds = productIds
        .where((String item) => item.trim().isNotEmpty)
        .map((String item) => item.trim().toLowerCase())
        .toSet();
    final Set<String> normalizedIngredients = activeIngredients
        .where((String item) => item.trim().isNotEmpty)
        .map((String item) => item.trim().toLowerCase())
        .toSet();

    if (normalizedProductIds.length < 2 &&
        normalizedIngredients.length < 2) {
      return const <DrugInteractionWarning>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('product_interactions')
        .get();

    final List<DrugInteractionWarning> warnings = <DrugInteractionWarning>[];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in snapshot.docs) {
      final Map<String, dynamic> data = document.data();
      final String productA = _readString(data, <String>[
        'product_id',
        'productId',
        'product_a_id',
        'productAId',
      ]);
      final String productB = _readString(data, <String>[
        'interacting_product_id',
        'interactingProductId',
        'product_b_id',
        'productBId',
      ]);
      final String ingredientA = _readString(data, <String>[
        'ingredient_a',
        'ingredientA',
        'active_ingredient_a',
      ]);
      final String ingredientB = _readString(data, <String>[
        'ingredient_b',
        'ingredientB',
        'active_ingredient_b',
      ]);

      final bool matchesByProduct =
          productA.isNotEmpty &&
          productB.isNotEmpty &&
          normalizedProductIds.contains(productA.toLowerCase()) &&
          normalizedProductIds.contains(productB.toLowerCase());
      final bool matchesByIngredient =
          ingredientA.isNotEmpty &&
          ingredientB.isNotEmpty &&
          normalizedIngredients.contains(ingredientA.toLowerCase()) &&
          normalizedIngredients.contains(ingredientB.toLowerCase());

      if (!matchesByProduct && !matchesByIngredient) continue;

      final String labelA = ingredientA.isNotEmpty ? ingredientA : productA;
      final String labelB = ingredientB.isNotEmpty ? ingredientB : productB;
      final String severity = _readString(data, <String>[
        'severity',
        'interaction_level',
        'interactionLevel',
      ]).toUpperCase();
      final String message = _readString(data, <String>[
        'warning_message',
        'message',
        'description',
        'recommendation',
      ]);

      warnings.add(
        DrugInteractionWarning(
          ingredientA: labelA,
          ingredientB: labelB,
          severity: severity.isEmpty ? 'MODERATE' : severity,
          message: message.isEmpty
              ? 'Phát hiện tương tác thuốc cần được dược sĩ kiểm tra.'
              : message,
        ),
      );
    }

    return warnings;
  }

  Future<String> createPrescription({
    required String branchId,
    required String pharmacistId,
    required String patientName,
    required String patientPhone,
    required String doctorName,
    required List<PrescriptionLine> items,
  }) async {
    if (items.isEmpty) {
      throw StateError('Đơn thuốc phải có ít nhất một thuốc.');
    }

    final DocumentReference<Map<String, dynamic>> prescriptionReference = _db
        .collection('prescriptions')
        .doc();
    final WriteBatch batch = _db.batch();
    final Timestamp now = Timestamp.now();

    batch.set(prescriptionReference, <String, dynamic>{
      'branch_id': branchId,
      'pharmacist_id': pharmacistId,
      'patient_name': patientName.trim(),
      'patient_phone': patientPhone.trim(),
      'doctor_name': doctorName.trim(),
      'prescription_number':
          'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'prescription_date': now,
      'status': 'VERIFIED',
      'notes': '',
      'created_at': now,
    });

    for (final PrescriptionLine item in items) {
      final DocumentReference<Map<String, dynamic>> itemReference = _db
          .collection('prescription_items')
          .doc();
      batch.set(itemReference, <String, dynamic>{
        'prescription_id': prescriptionReference.id,
        'product_id': item.productId,
        'inventory_id': item.inventoryId,
        'product_name': item.productName,
        'active_ingredient': item.activeIngredient,
        'batch_number': item.batchNumber,
        'dosage': item.dosage,
        'frequency': item.frequency,
        'duration': item.duration,
        'quantity': item.quantity.toString(),
        'instructions': item.instructions,
        'unit_price': item.unitPrice.toStringAsFixed(0),
      });
    }

    await batch.commit();
    return prescriptionReference.id;
  }

  Future<String> createDraftOrder({
    required String branchId,
    required String pharmacistId,
    required String? prescriptionId,
    required List<PharmacistCartItem> items,
  }) async {
    if (items.isEmpty) {
      throw StateError('Giỏ hàng đang trống.');
    }

    for (final PharmacistCartItem item in items) {
      if (item.quantity <= 0 || item.quantity > item.availableQuantity) {
        throw StateError('Số lượng ${item.productName} không hợp lệ.');
      }
    }

    final double subtotal = items.fold<double>(
      0,
      (double total, PharmacistCartItem item) => total + item.lineTotal,
    );
    const double discountAmount = 0;
    final double finalAmount = subtotal - discountAmount;

    final DocumentReference<Map<String, dynamic>> orderReference = _db
        .collection('orders')
        .doc();
    final WriteBatch batch = _db.batch();
    final Timestamp now = Timestamp.now();

    batch.set(orderReference, <String, dynamic>{
      'branch_id': branchId,
      'pharmacist_id': pharmacistId,
      // Keep this field for compatibility with existing reports.
      'cashier_id': pharmacistId,
      'prescription_id': prescriptionId,
      'order_type': prescriptionId == null ? 'otc' : 'prescription',
      'customer_phone': '',
      'subtotal': subtotal.toStringAsFixed(0),
      'discount_amount': discountAmount.toStringAsFixed(0),
      'total_amount': subtotal.toStringAsFixed(0),
      'final_amount': finalAmount.toStringAsFixed(0),
      'payment_method': null,
      'payment_status': 'unpaid',
      'invoice_number': null,
      'status': 'pending',
      'items': items
          .map((PharmacistCartItem item) => item.toEmbeddedMap())
          .toList(),
      'created_at': now,
      'updated_at': now,
    });

    for (final PharmacistCartItem item in items) {
      final DocumentReference<Map<String, dynamic>> itemReference = _db
          .collection('order_items')
          .doc();
      batch.set(itemReference, <String, dynamic>{
        'order_id': orderReference.id,
        'product_id': item.productId,
        'inventory_id': item.inventoryId,
        'product_name': item.productName,
        'active_ingredient': item.activeIngredient,
        'batch_number': item.batchNumber,
        'quantity': item.quantity.toString(),
        'price_per_unit': item.unitPrice.toStringAsFixed(0),
        'discount_amount': '0',
        'line_total': item.lineTotal.toStringAsFixed(0),
      });
    }

    await batch.commit();
    return orderReference.id;
  }

  Future<void> completePayment({
    required String orderId,
    required String paymentMethod,
    required String transactionReference,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> orderItemSnapshot = await _db
        .collection('order_items')
        .where('order_id', isEqualTo: orderId)
        .get();

    if (orderItemSnapshot.docs.isEmpty) {
      throw StateError('Không tìm thấy chi tiết đơn hàng.');
    }

    final Map<String, int> quantityByInventory = <String, int>{};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> document
        in orderItemSnapshot.docs) {
      final Map<String, dynamic> data = document.data();
      final String inventoryId = _readString(data, <String>[
        'inventory_id',
        'inventoryId',
      ]);
      final int quantity = _readInt(data, <String>['quantity']);
      if (inventoryId.isEmpty || quantity <= 0) {
        throw StateError('Chi tiết đơn hàng thiếu thông tin lô thuốc.');
      }
      quantityByInventory.update(
        inventoryId,
        (int oldValue) => oldValue + quantity,
        ifAbsent: () => quantity,
      );
    }

    final DocumentReference<Map<String, dynamic>> orderReference = _db
        .collection('orders')
        .doc(orderId);
    final String invoiceNumber =
        'HD-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

    await _db.runTransaction<void>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
          await transaction.get(orderReference);
      if (!orderSnapshot.exists) {
        throw StateError('Không tìm thấy đơn hàng.');
      }

      final String currentStatus = _readString(
        orderSnapshot.data() ?? <String, dynamic>{},
        <String>['status'],
      ).toLowerCase();
      if (currentStatus == 'completed') {
        throw StateError('Đơn hàng đã được thanh toán.');
      }

      final Map<DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>
      inventoryUpdates =
          <DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>{};

      for (final MapEntry<String, int> entry
          in quantityByInventory.entries) {
        final DocumentReference<Map<String, dynamic>> inventoryReference = _db
            .collection('inventories')
            .doc(entry.key);
        final DocumentSnapshot<Map<String, dynamic>> inventorySnapshot =
            await transaction.get(inventoryReference);
        if (!inventorySnapshot.exists) {
          throw StateError('Không tìm thấy lô thuốc ${entry.key}.');
        }

        final Map<String, dynamic> data =
            inventorySnapshot.data() ?? <String, dynamic>{};
        final int availableQuantity = _readInt(data, <String>['quantity']);
        if (availableQuantity < entry.value) {
          throw StateError('Tồn kho đã thay đổi, vui lòng kiểm tra lại.');
        }

        final DateTime? expiryDate = _readDate(data, <String>[
          'expiry_date',
          'expiryDate',
        ]);
        if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
          throw StateError('Không thể bán thuốc đã hết hạn.');
        }

        final int remainingQuantity = availableQuantity - entry.value;
        final int minimumStock = _readInt(data, <String>[
          'min_stock',
          'minimum_stock',
          'minimumStock',
        ]);
        inventoryUpdates[inventoryReference] = <String, dynamic>{
          'quantity': remainingQuantity.toString(),
          'stock_status': remainingQuantity <= 0
              ? 'OUT'
              : remainingQuantity <= minimumStock
              ? 'LOW'
              : 'NORMAL',
          'updated_at': Timestamp.now(),
        };
      }

      for (final MapEntry<DocumentReference<Map<String, dynamic>>,
              Map<String, dynamic>>
          update in inventoryUpdates.entries) {
        transaction.update(update.key, update.value);
      }

      transaction.update(orderReference, <String, dynamic>{
        'payment_method': paymentMethod,
        'payment_reference': transactionReference.trim(),
        'payment_status': 'paid',
        'paid_at': Timestamp.now(),
        'invoice_number': invoiceNumber,
        'status': 'completed',
        'updated_at': Timestamp.now(),
      });
    });
  }

  Future<PharmacistInvoice> fetchInvoice({required String orderId}) async {
    final DocumentSnapshot<Map<String, dynamic>> orderSnapshot = await _db
        .collection('orders')
        .doc(orderId)
        .get();
    if (!orderSnapshot.exists) {
      throw StateError('Không tìm thấy hóa đơn.');
    }

    final Map<String, dynamic> order =
        orderSnapshot.data() ?? <String, dynamic>{};
    final String branchId = _readString(order, <String>[
      'branch_id',
      'branchId',
    ]);
    final String pharmacistId = _readString(order, <String>[
      'pharmacist_id',
      'cashier_id',
      'pharmacistId',
    ]);

    final List<Future<dynamic>> futures = <Future<dynamic>>[
      _db
          .collection('order_items')
          .where('order_id', isEqualTo: orderId)
          .get(),
      branchId.isEmpty
          ? Future<DocumentSnapshot<Map<String, dynamic>>?>.value(null)
          : _db.collection('branches').doc(branchId).get(),
      pharmacistId.isEmpty
          ? Future<DocumentSnapshot<Map<String, dynamic>>?>.value(null)
          : _db.collection('users').doc(pharmacistId).get(),
    ];

    final List<dynamic> results = await Future.wait<dynamic>(futures);
    final QuerySnapshot<Map<String, dynamic>> itemSnapshot =
        results[0] as QuerySnapshot<Map<String, dynamic>>;
    final DocumentSnapshot<Map<String, dynamic>>? branchSnapshot =
        results[1] as DocumentSnapshot<Map<String, dynamic>>?;
    final DocumentSnapshot<Map<String, dynamic>>? userSnapshot =
        results[2] as DocumentSnapshot<Map<String, dynamic>>?;

    final List<PharmacistInvoiceLine> lines = itemSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
          final Map<String, dynamic> data = document.data();
          return PharmacistInvoiceLine(
            productName: _readString(data, <String>[
              'product_name',
              'productName',
            ]),
            batchNumber: _readString(data, <String>[
              'batch_number',
              'batchNumber',
            ]),
            quantity: _readInt(data, <String>['quantity']),
            unitPrice: _readDouble(data, <String>[
              'price_per_unit',
              'unit_price',
              'price',
            ]),
          );
        })
        .toList();

    final Map<String, dynamic> branch =
        branchSnapshot?.data() ?? <String, dynamic>{};
    final Map<String, dynamic> user =
        userSnapshot?.data() ?? <String, dynamic>{};

    return PharmacistInvoice(
      orderId: orderId,
      invoiceNumber: _readString(order, <String>['invoice_number']).isEmpty
          ? orderId
          : _readString(order, <String>['invoice_number']),
      branchName: _readString(branch, <String>[
        'branch_name',
        'name',
      ]).isEmpty
          ? branchId
          : _readString(branch, <String>['branch_name', 'name']),
      pharmacistName: _readString(user, <String>[
        'displayName',
        'full_name',
        'name',
      ]).isEmpty
          ? pharmacistId
          : _readString(user, <String>[
              'displayName',
              'full_name',
              'name',
            ]),
      issuedAt:
          _readDate(order, <String>['paid_at', 'updated_at', 'created_at']) ??
          DateTime.now(),
      paymentMethod: _readString(order, <String>['payment_method']),
      subtotal: _readDouble(order, <String>['subtotal', 'total_amount']),
      discountAmount: _readDouble(order, <String>['discount_amount']),
      totalAmount: _readDouble(order, <String>[
        'final_amount',
        'total_amount',
      ]),
      lines: lines,
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static int _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final int? parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static double _readDouble(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value is num) return value.toDouble();
      final double? parsed = double.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value is bool) return value;
      final String normalized = value?.toString().trim().toLowerCase() ?? '';
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return false;
  }

  static DateTime? _readDate(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      final DateTime? parsed = DateTime.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }
}
