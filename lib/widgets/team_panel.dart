import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';

class TeamPanel extends StatelessWidget {
  final TeamManager teamManager;
  final bool canCopyList;

  const TeamPanel({
    super.key,
    required this.teamManager,
    this.canCopyList = false,
  });

  String _buildFormattedTeamsList(List<Team> teams) {
    final buffer = StringBuffer('-- Sorteo de equipos --\n\n');
    for (int i = 0; i < teams.length; i++) {
      final team = teams[i];
      buffer.writeln('${team.name} (${team.memberCount}):');
      for (final member in team.members) {
        buffer.writeln('- ${member.name}');
      }
      if (i < teams.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString().trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final teams = teamManager.teams;
    if (teams.isEmpty) return const SizedBox.shrink();
    final isCompact = MediaQuery.of(context).size.width < 480;

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
          if (isCompact) ...[
            Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: AppPalette.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Equipos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
            if (canCopyList)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final listText = _buildFormattedTeamsList(teams);
                    await Clipboard.setData(ClipboardData(text: listText));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lista copiada al portapapeles'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.content_copy_rounded, size: 14),
                  label: const Text('Copiar lista'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppPalette.muted,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ] else
            Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: AppPalette.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Equipos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canCopyList) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final listText = _buildFormattedTeamsList(teams);
                      await Clipboard.setData(ClipboardData(text: listText));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lista copiada al portapapeles'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.content_copy_rounded, size: 14),
                    label: const Text('Copiar lista'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.muted,
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final minColumnWidth = constraints.maxWidth < 520 ? 150.0 : 180.0;
              final columns =
                  (constraints.maxWidth / minColumnWidth).floor().clamp(
                        1,
                        teams.length,
                      );
              final columnWidth =
                  (constraints.maxWidth - (columns - 1) * 10) / columns;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: teams
                    .map(
                      (team) => SizedBox(
                        width: columnWidth.clamp(0, constraints.maxWidth),
                        child: _TeamColumn(team: team),
                      ),
                    )
                    .toList(),
              );
            },
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
        border: Border.all(color: team.color.withValues(alpha: 0.2)),
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
