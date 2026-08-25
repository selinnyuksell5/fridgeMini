class Ingredient {
  final String name;
  final double? amount;
  final String? unit;
  final bool isAvailable;

  Ingredient({
    required this.name,
    this.amount,
    this.unit,
    this.isAvailable = true,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: json['amount']?.toDouble(),
      unit: json['unit'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      'isAvailable': isAvailable,
    };
  }

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    bool? isAvailable,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
