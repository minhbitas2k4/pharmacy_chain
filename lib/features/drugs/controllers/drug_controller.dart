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
