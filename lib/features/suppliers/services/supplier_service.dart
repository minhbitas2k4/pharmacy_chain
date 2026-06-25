import '../models/supplier_model.dart';

class SupplierService {
  Future<List<SupplierModel>> fetchSuppliers() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const <SupplierModel>[
      SupplierModel(
        name: 'MediCorp Pharma',
        rating: 4.8,
        reviews: 124,
        status: 'ACTIVE',
        contact: '090-123-4567',
        lastTransaction: 'Oct 12, 2023',
        address: '15 Le Duan, Dist 1, HCMC',
      ),
      SupplierModel(
        name: 'An Khang Supply',
        rating: 4.6,
        reviews: 86,
        status: 'ACTIVE',
        contact: '090-987-1122',
        lastTransaction: 'Nov 03, 2023',
        address: '23 Nguyen Hue, Dist 1, HCMC',
      ),
      SupplierModel(
        name: 'GreenMed Distributor',
        rating: 4.3,
        reviews: 57,
        status: 'ACTIVE',
        contact: '091-555-7711',
        lastTransaction: 'Dec 21, 2023',
        address: '88 Tran Phu, Da Nang',
      ),
    ];
  }
}
