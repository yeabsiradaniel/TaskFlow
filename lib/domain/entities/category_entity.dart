import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int colorValue;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, colorValue];
}
