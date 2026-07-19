import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/drug_model.dart';

class DrugService {
  DrugService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<DrugModel>> fetchDrugs() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('drugs')
        .orderBy('name')
        .get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
      return DrugModel(
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
