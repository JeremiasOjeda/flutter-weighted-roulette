import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';
import 'roulette_wheel.dart';

class ControlPanel extends StatefulWidget {
  final ParticipantManager manager;
  final AppMode mode;
  final int teamCount;
  final bool isSpinning;
  final VoidCallback onSpin;
  final VoidCallback onRestoreAll;
  final ValueChanged<int> onRemove;
  final void Function(int index, double weight) onWeightChanged;
  final VoidCallback onChanged;
  final ValueChanged<AppMode> onModeChanged;
  final ValueChanged<int> onTeamCountChanged;

  const ControlPanel({
    super.key,
    required this.manager,
    required this.mode,
    required this.teamCount,
    required this.isSpinning,
    required this.onSpin,
    required this.onRestoreAll,
    required this.onRemove,
    required this.onWeightChanged,
    required this.onChanged,
    required this.onModeChanged,
    required this.onTeamCountChanged,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  void _addParticipant() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.manager.add(name);
    _nameController.clear();
    _focusNode.requestFocus();
    widget.onChanged();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.manager;
    final participants = manager.all;
    final hasDiscarded = participants.any((p) => p.isDiscarded);
    final isTeams = widget.mode == AppMode.teams;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _ModeToggle(
              mode: widget.mode,
              onChanged: widget.isSpinning ? null : widget.onModeChanged,
            ),
          ),
          // Team count selector
          if (isTeams)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _TeamCountSelector(
                count: widget.teamCount,
                enabled: !widget.isSpinning,
                onChanged: widget.onTeamCountChanged,
              ),
            ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Text(
                  isTeams ? 'Participantes pendientes' : 'Participantes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.text,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppPalette.cyan.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppPalette.cyan.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '${manager.activeCount}/${manager.totalCount}',
                    style: const TextStyle(
                      color: AppPalette.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Add participant input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _addParticipant(),
                    enabled: !widget.isSpinning && manager.totalCount < 50,
                    style: const TextStyle(
                      color: AppPalette.text,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nombre del participante',
                      hintStyle: const TextStyle(color: AppPalette.muted),
                      filled: true,
                      fillColor: AppPalette.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppPalette.cyan.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _IconBtn(
                  icon: Icons.add_rounded,
                  onPressed: widget.isSpinning || manager.totalCount >= 50
                      ? null
                      : _addParticipant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Participant list
          Expanded(
            child: participants.isEmpty
                ? Center(
                    child: Text(
                      isTeams
                          ? 'Agrega participantes para armar equipos'
                          : 'Agrega al menos 1 participante',
                      style: const TextStyle(
                        color: AppPalette.muted,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: participants.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final p = participants[index];
                      return _ParticipantTile(
                        participant: p,
                        index: index,
                        color: kWheelColors[index % kWheelColors.length],
                        isSpinning: widget.isSpinning,
                        showWeights: !isTeams,
                        onRemove: () => widget.onRemove(index),
                        onWeightChanged: (w) =>
                            widget.onWeightChanged(index, w),
                      );
                    },
                  ),
          ),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasDiscarded && !isTeams) ...[
                  TextButton.icon(
                    onPressed: widget.isSpinning ? null : widget.onRestoreAll,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Restaurar descartados'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.muted,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                _SpinButton(
                  canSpin: manager.canSpin && !widget.isSpinning,
                  isSpinning: widget.isSpinning,
                  label: isTeams ? '🎲  Sortear' : '🎰  Girar',
                  onPressed: widget.onSpin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final AppMode mode;
  final ValueChanged<AppMode>? onChanged;

  const _ModeToggle({required this.mode, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Solo',
            icon: Icons.person_rounded,
            isActive: mode == AppMode.solo,
            onTap: onChanged == null ? null : () => onChanged!(AppMode.solo),
          ),
          _ToggleOption(
            label: 'Equipos',
            icon: Icons.groups_rounded,
            isActive: mode == AppMode.teams,
            onTap: onChanged == null ? null : () => onChanged!(AppMode.teams),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppPalette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppPalette.cyan.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ]
                : null,
            border: isActive
                ? Border.all(
                    color: AppPalette.cyan.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? AppPalette.cyan
                    : AppPalette.muted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppPalette.cyan
                      : AppPalette.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamCountSelector extends StatelessWidget {
  final int count;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _TeamCountSelector({
    required this.count,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Equipos:',
          style: TextStyle(
            color: AppPalette.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        for (int i = 2; i <= 4; i++) ...[
          _CountChip(
            value: i,
            isSelected: count == i,
            onTap: enabled ? () => onChanged(i) : null,
          ),
          if (i < 4) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CountChip({
    required this.value,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppPalette.blue.withValues(alpha: 0.15)
              : AppPalette.surfaceVariant,
          border: Border.all(
            color: isSelected
                ? AppPalette.blue.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppPalette.blue
                : AppPalette.muted,
          ),
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  final int index;
  final Color color;
  final bool isSpinning;
  final bool showWeights;
  final VoidCallback onRemove;
  final ValueChanged<double> onWeightChanged;

  const _ParticipantTile({
    required this.participant,
    required this.index,
    required this.color,
    required this.isSpinning,
    required this.showWeights,
    required this.onRemove,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final discarded = participant.isDiscarded;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: discarded ? 0.35 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppPalette.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    participant.name,
                    style: TextStyle(
                      color: AppPalette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration:
                          discarded ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!discarded && showWeights)
                  Text(
                    '${participant.weight.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 4),
                if (!isSpinning)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppPalette.muted.withValues(alpha: 0.6),
                      ),
                      onPressed: onRemove,
                    ),
                  ),
              ],
            ),
            if (!discarded && !isSpinning && showWeights)
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: color,
                  inactiveTrackColor: color.withValues(alpha: 0.15),
                  thumbColor: color,
                  overlayColor: color.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: participant.weight.clamp(1, 99),
                  min: 1,
                  max: 99,
                  onChanged: onWeightChanged,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  final bool canSpin;
  final bool isSpinning;
  final String label;
  final VoidCallback onPressed;

  const _SpinButton({
    required this.canSpin,
    required this.isSpinning,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: canSpin ? 1.0 : 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppPalette.cyan, AppPalette.blue],
          ),
          boxShadow: canSpin
              ? [
                  BoxShadow(
                    color: AppPalette.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: canSpin ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isSpinning ? 'Girando...' : label,
            style: TextStyle(
              color: canSpin ? AppPalette.background : AppPalette.muted,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconBtn({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppPalette.cyan, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: AppPalette.cyan.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: AppPalette.cyan.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
    );
  }
}
