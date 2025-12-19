class Court {
  final String id;
  final String name;

  Court({required this.id, required this.name});

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Court && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
