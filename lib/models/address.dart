class Address {
  final String id;
  final String label;
  final String line1;
  final String city;
  final String phone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? label,
    String? line1,
    String? city,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      line1: line1 ?? this.line1,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullLine => '$line1, $city';
}
