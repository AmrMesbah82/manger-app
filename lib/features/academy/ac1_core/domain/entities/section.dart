/// Module: academy / ac1_core
///
///*************************** FILE INFO ****************************///
/// File Name: section.dart
/// Purpose: Declares `Section` — a class group of students.
/// Author: Manger Plus team
/// Created: 18/9/2026

/// A group the admin puts students into ("Grade 3 — A"). Content is assigned
/// to a section or to single students; attendance is taken per section.
///
/// Which teachers teach a section is stored on the TEACHER (`section_ids`),
/// not here: that is the list the rules and the teacher's queries read, and
/// keeping a second copy on the section would be a second thing to get out
/// of step.
class Section {
  final String id;
  final String name;

  /// Free text — "Grade 3", "Level B1", "Year 10". The center's own words.
  final String level;
  final String description;
  final bool demo;
  final DateTime? createdAt;

  const Section({
    required this.id,
    required this.name,
    this.level = '',
    this.description = '',
    this.demo = false,
    this.createdAt,
  });

  String get title => level.trim().isEmpty ? name : '$name · $level';

  Section copyWith({String? id, String? name, String? level, String? description}) {
    return Section(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      demo: demo,
      createdAt: createdAt,
    );
  }
}
