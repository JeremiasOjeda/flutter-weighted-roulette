import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';

class TeamPanel extends StatelessWidget {
  final TeamManager teamManager;

  const TeamPanel({super.key, required this.teamManager});

  @override
  Widget build(BuildContext context) {
    final teams = teamManager.teams;
    if (teams.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.groups_rounded,
                color: AppPalette.blue,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Equipos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppPalette.blue.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppPalette.blue.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '${teamManager.totalMembers} asignados',
                  style: const TextStyle(
                    color: AppPalette.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = teams.length <= 2 ? 2 : teams.length;
                final columnWidth =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: teams
                      .map((team) => SizedBox(
                            width: columnWidth.clamp(0, constraints.maxWidth),
                            child: _TeamColumn(team: team),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final Team team;

  const _TeamColumn({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: team.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: team.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: team.color,
                    boxShadow: [
                      BoxShadow(
                        color: team.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team.name,
                    style: TextStyle(
                      color: team.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${team.memberCount}',
                  style: TextStyle(
                    color: team.color.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (team.members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Sin miembros',
                style: TextStyle(
                  color: AppPalette.muted,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...team.members.map(
              (member) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Text(
                  member.name,
                  style: const TextStyle(
                    color: AppPalette.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
