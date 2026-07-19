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
    this.id,
    required this.name,
    required this.activeIngredient,
    required this.strength,
    required this.dosageForm,
    required this.packaging,
    required this.price,
    required this.filter,
  });

  final String? id;
  final String name;
  final String activeIngredient;
  final String strength;
  final String dosageForm;
  final String packaging;
  final String price;
  final DrugFilter filter;

  DrugModel copyWith({
    String? id,
    String? name,
    String? activeIngredient,
    String? strength,
    String? dosageForm,
    String? packaging,
    String? price,
    DrugFilter? filter,
  }) {
    return DrugModel(
      id: id ?? this.id,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      packaging: packaging ?? this.packaging,
      price: price ?? this.price,
      filter: filter ?? this.filter,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product_name': name,
      'active_ingredient': activeIngredient,
      'dosage': strength,
      'indications': dosageForm,
      'packaging': packaging,
      'price': price,
      'shift_location': filter == DrugFilter.prescription ? 'Quay B' : 'Quay A',
    };
  }
}
