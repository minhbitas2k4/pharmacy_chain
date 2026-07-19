import 'package:flutter/foundation.dart';

import '../models/drug_model.dart';
import '../services/drug_service.dart';

class DrugController extends ChangeNotifier {
  DrugController({DrugService? drugService})
    : _drugService = drugService ?? DrugService();

  final DrugService _drugService;

  bool _isLoading = false;
  String _query = '';
  DrugFilter _selectedFilter = DrugFilter.all;
  List<DrugModel> _drugs = <DrugModel>[];

  bool get isLoading => _isLoading;
  DrugFilter get selectedFilter => _selectedFilter;
  List<DrugModel> get drugs {
    return List<DrugModel>.unmodifiable(
      _drugs.where((DrugModel drug) {
        final bool matchesFilter =
            _selectedFilter == DrugFilter.all || drug.filter == _selectedFilter;
        final String searchTarget = '${drug.name} ${drug.activeIngredient}'
            .toLowerCase();
        return matchesFilter && searchTarget.contains(_query.toLowerCase());
      }),
    );
  }

  Future<void> loadDrugs() async {
    _setLoading(true);
    try {
      _drugs = await _drugService.fetchDrugs();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addDrug(DrugModel drug) async {
    try {
      await _drugService.createDrug(drug);
      // Reload from DB to get the generated id
      await loadDrugs();
    } catch (_) {}
  }

  Future<void> updateDrug(DrugModel drug) async {
    try {
      await _drugService.updateDrug(drug);
      final int index = _drugs.indexWhere((DrugModel element) => element.id == drug.id);
      if (index != -1) {
        _drugs[index] = drug;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> deleteDrug(String drugId) async {
    try {
      await _drugService.deleteDrug(drugId);
      _drugs.removeWhere((DrugModel element) => element.id == drugId);
      notifyListeners();
    } catch (_) {}
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void selectFilter(DrugFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
