import 'person_position.dart';

class PoseTemplate {
  final String id;
  final String name;
  final int peopleCount;
  final List<String> ageGroups;
  final String style;
  final List<PersonPosition> positions;
  final String layoutDescription;

  const PoseTemplate({
    required this.id,
    required this.name,
    required this.peopleCount,
    this.ageGroups = const ['青年'],
    this.style = 'casual',
    required this.positions,
    this.layoutDescription = '',
  });
}
