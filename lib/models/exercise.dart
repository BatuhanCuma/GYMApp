class Exercise {
  final int? id;
  final String name;
  final double weight;
  final int categoryId;
  final bool isDone;

  Exercise({
    this.id,
    required this.name,
    required this.weight,
    required this.categoryId,
    this.isDone = false,
  });

  Exercise copyWith({
    int? id,
    String? name,
    double? weight,
    int? categoryId,
    bool? isDone,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        weight: weight ?? this.weight,
        categoryId: categoryId ?? this.categoryId,
        isDone: isDone ?? this.isDone,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'weight': weight,
        'category_id': categoryId,
        'is_done': isDone ? 1 : 0,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int?,
        name: map['name'] as String,
        weight: (map['weight'] as num).toDouble(),
        categoryId: map['category_id'] as int,
        isDone: (map['is_done'] as int) == 1,
      );
}
