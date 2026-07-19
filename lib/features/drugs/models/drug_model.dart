enum DrugFilter { all, prescription, vitamin }

extension DrugFilterX on DrugFilter {
  String get label {
    switch (this) {
      case DrugFilter.all:
        return 'Tất cả';
      case DrugFilter.prescription:
        return 'Kê đơn';
      case DrugFilter.vitamin:
        return 'Vitamin';
    }
  }
}

class DrugModel {
  const DrugModel({
    required this.name,
    required this.activeIngredient,
    required this.strength,
    required this.dosageForm,
    required this.packaging,
    required this.price,
    required this.filter,
  });

  final String name;
  final String activeIngredient;
  final String strength;
  final String dosageForm;
  final String packaging;
  final String price;
  final DrugFilter filter;
}
