import 'package:flutter/material.dart';

enum AppMode { solo, teams }

class Participant {
  final String name;
  double weight;
  bool isDiscarded;

  Participant({
    required this.name,
    this.weight = 0,
    this.isDiscarded = false,
  });

  double get activeWeight => isDiscarded ? 0 : weight;
}

class Team {
  final String name;
  final Color color;
  final List<Participant> members;

  Team({required this.name, required this.color}) : members = [];

  int get memberCount => members.length;
}

/// Team configs indexed by team count. Green + Red are always first.
const Map<int, List<(String, Color)>> kTeamConfigs = {
  2: [
    ('Equipo Verde', Color(0xFF2ECC71)),
    ('Equipo Rojo', Color(0xFFE74C3C)),
  ],
  3: [
    ('Equipo Verde', Color(0xFF2ECC71)),
    ('Equipo Rojo', Color(0xFFE74C3C)),
    ('Equipo Azul', Color(0xFF3498DB)),
  ],
  4: [
    ('Equipo Verde', Color(0xFF2ECC71)),
    ('Equipo Rojo', Color(0xFFE74C3C)),
    ('Equipo Azul', Color(0xFF3498DB)),
    ('Equipo Naranja', Color(0xFFF39C12)),
  ],
};

class TeamManager {
  final List<Team> _teams = [];

  List<Team> get teams => List.unmodifiable(_teams);
  int get teamCount => _teams.length;

  void initialize(int count) {
    _teams.clear();
    final clamped = count.clamp(2, 4);
    final config = kTeamConfigs[clamped]!;
    for (final (name, color) in config) {
      _teams.add(Team(name: name, color: color));
    }
  }

  /// Assigns participant to the team with fewest members (balanced).
  Team assignToSmallest(Participant participant) {
    final sorted = List<Team>.from(_teams)
      ..sort((a, b) => a.memberCount.compareTo(b.memberCount));
    final target = sorted.first;
    target.members.add(participant);
    return target;
  }

  void clear() {
    for (final team in _teams) {
      team.members.clear();
    }
  }

  bool get allAssigned => true;

  int get totalMembers =>
      _teams.fold<int>(0, (sum, t) => sum + t.memberCount);
}

class ParticipantManager {
  final List<Participant> _participants = [];

  List<Participant> get all => List.unmodifiable(_participants);

  List<Participant> get active =>
      _participants.where((p) => !p.isDiscarded).toList();

  int get totalCount => _participants.length;
  int get activeCount => active.length;
  bool get canSpin => activeCount >= 1;

  void add(String name) {
    if (name.trim().isEmpty || _participants.length >= 50) return;
    _participants.add(Participant(name: name.trim()));
    _distributeEqual();
  }

  void remove(int index) {
    if (index < 0 || index >= _participants.length) return;
    _participants.removeAt(index);
    if (_participants.isNotEmpty) _distributeEqual();
  }

  void discard(int index) {
    if (index < 0 || index >= _participants.length) return;
    _participants[index].isDiscarded = true;
    _normalizeActiveWeights();
  }

  void restoreAll() {
    for (final p in _participants) {
      p.isDiscarded = false;
    }
    _distributeEqual();
  }

  void setWeight(int index, double newWeight) {
    if (index < 0 || index >= _participants.length) return;
    final participant = _participants[index];
    if (participant.isDiscarded) return;

    final actives = active;
    if (actives.length < 2) return;

    final clamped = newWeight.clamp(1.0, 99.0);
    final oldWeight = participant.weight;
    participant.weight = clamped;

    final delta = clamped - oldWeight;
    final others = actives.where((p) => p.name != participant.name).toList();
    final othersTotal = others.fold<double>(0, (s, p) => s + p.weight);

    if (othersTotal <= 0) return;

    for (final other in others) {
      final share = other.weight / othersTotal;
      other.weight = (other.weight - delta * share).clamp(1.0, 99.0);
    }
    _normalizeActiveWeights();
  }

  List<double> get normalizedWeights {
    final actives = active;
    if (actives.isEmpty) return [];
    final total = actives.fold<double>(0, (s, p) => s + p.weight);
    if (total <= 0) return List.filled(actives.length, 1.0 / actives.length);
    return actives.map((p) => p.weight / total).toList();
  }

  int selectWeightedRandom(double randomValue) {
    final weights = normalizedWeights;
    final actives = active;
    double cumulative = 0;
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (randomValue <= cumulative) {
        return _participants.indexOf(actives[i]);
      }
    }
    return _participants.indexOf(actives.last);
  }

  void _distributeEqual() {
    final actives = active;
    if (actives.isEmpty) return;
    final each = 100.0 / actives.length;
    for (final p in actives) {
      p.weight = each;
    }
  }

  void _normalizeActiveWeights() {
    final actives = active;
    if (actives.isEmpty) return;
    final total = actives.fold<double>(0, (s, p) => s + p.weight);
    if (total <= 0) {
      _distributeEqual();
      return;
    }
    for (final p in actives) {
      p.weight = (p.weight / total) * 100;
    }
  }
}
