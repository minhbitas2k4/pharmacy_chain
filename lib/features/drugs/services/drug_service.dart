import '../models/drug_model.dart';

class DrugService {
  Future<List<DrugModel>> fetchDrugs() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const <DrugModel>[
      DrugModel(
        name: 'Amoxicillin 500mg',
        activeIngredient: 'Amoxicillin',
        strength: '500mg',
        dosageForm: 'Viên nén',
        packaging: 'Hộp 20 viên',
        price: '85.000đ',
        filter: DrugFilter.prescription,
      ),
      DrugModel(
        name: 'Vitamin C 1000mg',
        activeIngredient: 'Ascorbic Acid',
        strength: '1000mg',
        dosageForm: 'Viên sủi',
        packaging: 'Hộp 10 viên',
        price: '48.000đ',
        filter: DrugFilter.vitamin,
      ),
      DrugModel(
        name: 'Paracetamol 500mg',
        activeIngredient: 'Paracetamol',
        strength: '500mg',
        dosageForm: 'Viên nén',
        packaging: 'Hộp 10 vỉ',
        price: '32.000đ',
        filter: DrugFilter.prescription,
      ),
    ];
  }
}
