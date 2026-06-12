class Exercise {
  final int? id;
  final String name;
  final double weight;

  Exercise({this.id, required this.name, required this.weight});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'weight': weight,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int?,
        name: map['name'] as String,
        weight: (map['weight'] as num).toDouble(),
      );
}
