import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/drug_model.dart';

class DrugService {
  DrugService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<DrugModel>> fetchDrugs() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('products')
          .orderBy('product_name')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
          final String name = data['product_name']?.toString() ?? '';
          final String activeIngredient = data['active_ingredient']?.toString() ?? '';
          final String strength = data['dosage']?.toString() ?? '';
          final String dosageForm = data['indications']?.toString() ?? '';
          final String packaging = data['packaging']?.toString() ?? 'Hộp 10 vỉ x 10 viên';
          final String price = data['price']?.toString() ?? '125.000đ';
          
          DrugFilter filter = DrugFilter.all;
          final String location = (data['shift_location']?.toString() ?? '').toLowerCase();
          if (location.contains('b')) {
            filter = DrugFilter.prescription;
          } else {
            filter = DrugFilter.vitamin;
          }

          return DrugModel(
            id: doc.id,
            name: name,
            activeIngredient: activeIngredient,
            strength: strength,
            dosageForm: dosageForm,
            packaging: packaging,
            price: price,
            filter: filter,
          );
        }).toList();
      }
    } catch (_) {}

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('drugs')
          .orderBy('name')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
          return DrugModel(
            id: doc.id,
            name: data['name']?.toString() ?? '',
            activeIngredient: data['activeIngredient']?.toString() ?? '',
            strength: data['strength']?.toString() ?? '',
            dosageForm: data['dosageForm']?.toString() ?? '',
            packaging: data['packaging']?.toString() ?? '',
            price: data['price']?.toString() ?? '',
            filter: _filterFromString(data['filter']?.toString()),
          );
        }).toList();
      }
    } catch (_) {}

    // Ultimate fallback/Default mock drugs if Firestore has no records
    final fallbacks = <DrugModel>[
      const DrugModel(
        id: 'product_001',
        name: 'Paracetamol 500mg',
        activeIngredient: 'Paracetamol',
        strength: '500mg',
        dosageForm: 'Viên nén',
        packaging: 'Hộp 10 vỉ x 10 viên',
        price: '125.000đ',
        filter: DrugFilter.vitamin,
      ),
      const DrugModel(
        id: 'product_002',
        name: 'Amoxicillin 250mg',
        activeIngredient: 'Amoxicillin',
        strength: '250mg',
        dosageForm: 'Viên nang',
        packaging: 'Hộp 10 vỉ x 10 viên',
        price: '60.000đ',
        filter: DrugFilter.prescription,
      ),
      const DrugModel(
        id: 'product_003',
        name: 'Ibuprofen 200mg',
        activeIngredient: 'Ibuprofen',
        strength: '200mg',
        dosageForm: 'Viên nén bao phim',
        packaging: 'Hộp 5 vỉ x 10 viên',
        price: '45.000đ',
        filter: DrugFilter.vitamin,
      ),
    ];

    for (final d in fallbacks) {
      createDrug(d).catchError((_) {});
    }

    return fallbacks;
  }

  Future<void> createDrug(DrugModel drug) async {
    await _firestore.collection('products').add(<String, dynamic>{
      'product_name': drug.name,
      'active_ingredient': drug.activeIngredient,
      'dosage': drug.strength,
      'indications': drug.dosageForm,
      'shift_location': drug.filter == DrugFilter.prescription ? 'Quay B' : 'Quay A',
      'packaging': drug.packaging,
      'price': drug.price,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDrug(DrugModel drug) async {
    if (drug.id == null) return;
    await _firestore
        .collection('products')
        .doc(drug.id)
        .set(drug.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteDrug(String drugId) async {
    await _firestore.collection('products').doc(drugId).delete();
  }

  DrugFilter _filterFromString(String? value) {
    switch (value) {
      case 'vitamin':
        return DrugFilter.vitamin;
      case 'prescription':
        return DrugFilter.prescription;
      default:
        return DrugFilter.all;
    }
  }
}
