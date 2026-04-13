import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/participant.dart';
import '../theme/app_palette.dart';
import '../widgets/control_panel.dart';
import '../widgets/roulette_wheel.dart';
import '../widgets/team_panel.dart';
import '../widgets/winner_overlay.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
  final _manager = ParticipantManager();
  final _teamManager = TeamManager();
  final _random = math.Random();

  late final AnimationController _spinController;
  late final Animation<double> _spinAnimation;

  AppMode _mode = AppMode.solo;
  int _teamCount = 2;
  double _currentAngle = 0;
  double _startAngle = 0;
  double _spinDelta = 0;
  bool _isSpinning = false;
  bool _isHelpVisible = false;
  int? _winnerIndex;
  Team? _lastAssignedTeam;

  @override
  void initState() {
    super.initState();
    _teamManager.initialize(_teamCount);

    _spinController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );
    _spinController.addListener(() {
      setState(() {
        _currentAngle = _startAngle + _spinDelta * _spinAnimation.value;
      });
    });
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _currentAngle = _currentAngle % (2 * math.pi);
        });
        _onSpinComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHelpModal();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (!_manager.canSpin || _isSpinning) return;

    final randomValue = _random.nextDouble();
    final winnerGlobalIndex = _manager.selectWeightedRandom(randomValue);

    final active = _manager.active;
    final weights = _manager.normalizedWeights;
    final winnerActiveIndex = active.indexOf(_manager.all[winnerGlobalIndex]);

    // Calculate the angle from the wheel's start (top) to the winner segment
    double angleToWinner = 0;
    for (int i = 0; i < winnerActiveIndex; i++) {
      angleToWinner += weights[i] * 2 * math.pi;
    }
    final segmentSweep = weights[winnerActiveIndex] * 2 * math.pi;
    final offsetInSegment = segmentSweep * (0.2 + _random.nextDouble() * 0.6);
    angleToWinner += offsetInSegment;

    // For the winner to land under the indicator (top), the final absolute
    // angle must satisfy: finalAngle % 2π == (2π - angleToWinner) % 2π
    final fullRotations = (3 + _random.nextInt(3)) * 2 * math.pi;
    final normalizedCurrent = _currentAngle % (2 * math.pi);
    final desiredFinal = (2 * math.pi - angleToWinner) % (2 * math.pi);

    var delta = desiredFinal - normalizedCurrent;
    if (delta < 0) delta += 2 * math.pi;

    _startAngle = _currentAngle;
    _spinDelta = fullRotations + delta;
    _winnerIndex = winnerGlobalIndex;
    _lastAssignedTeam = null;

    setState(() => _isSpinning = true);
    _spinController.reset();
    _spinController.forward();
  }

  void _onSpinComplete() {
    if (_winnerIndex == null) return;
    final winner = _manager.all[_winnerIndex!];

    if (_mode == AppMode.teams) {
      final team = _teamManager.assignToSmallest(
        Participant(name: winner.name),
      );
      _lastAssignedTeam = team;
      _manager.discard(_winnerIndex!);
      setState(() {});
    }

    _showResultOverlay();
  }

  void _showResultOverlay() {
    if (_winnerIndex == null) return;
    final winner = _manager.all[_winnerIndex!];

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => WinnerOverlay(
        winnerName: winner.name,
        mode: _mode,
        assignedTeam: _lastAssignedTeam,
        onPrimary: () {
          Navigator.of(context).pop();
          if (_mode == AppMode.solo) {
            setState(() {
              _manager.discard(_winnerIndex!);
              _winnerIndex = null;
            });
          } else {
            setState(() => _winnerIndex = null);
          }
        },
        onClose: () {
          Navigator.of(context).pop();
          setState(() => _winnerIndex = null);
        },
      ),
    );
  }

  void _handleModeChanged(AppMode newMode) {
    setState(() {
      _mode = newMode;
      _manager.restoreAll();
      _teamManager.clear();
      _teamManager.initialize(_teamCount);
      _winnerIndex = null;
      _lastAssignedTeam = null;
    });
  }

  void _handleTeamCountChanged(int count) {
    setState(() {
      _teamCount = count;
      _teamManager.initialize(count);
      _manager.restoreAll();
      _winnerIndex = null;
    });
  }

  void _handleWeightChanged(int index, double weight) {
    setState(() => _manager.setWeight(index, weight));
  }

  void _handleRemove(int index) {
    setState(() => _manager.remove(index));
  }

  void _handleRestoreAll() {
    setState(() {
      _manager.restoreAll();
      if (_mode == AppMode.teams) _teamManager.clear();
    });
  }

  Future<void> _openMainSite() async {
    await launchUrlString('https://soyjere.com');
  }

  void _showHelpModal() {
    if (_isHelpVisible) return;
    _isHelpVisible = true;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Como usar la ruleta',
                style: TextStyle(
                  color: AppPalette.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '1) Agrega participantes.\n'
                '2) Elige modo Solo o Equipos.\n'
                '3) Presiona Girar/Sortear para seleccionar ganador.\n'
                '4) En modo Solo, puedes descartar ganadores y continuar.',
                style: TextStyle(
                  color: AppPalette.muted,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.cyan,
                    foregroundColor: AppPalette.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      _isHelpVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppPalette.background,
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                ),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _openMainSite,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('soyjere.com'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.cyan,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _showHelpModal,
                    tooltip: 'Como funciona',
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

            final wheelWidget = Padding(
              padding: EdgeInsets.all(isWide ? 24 : 8),
              child: RouletteWheel(
                participants: _manager.active,
                normalizedWeights: _manager.normalizedWeights,
                rotationAngle: _currentAngle,
              ),
            );

            final panelWidget = ControlPanel(
              manager: _manager,
              mode: _mode,
              teamCount: _teamCount,
              isSpinning: _isSpinning,
              onSpin: _spin,
              onRestoreAll: _handleRestoreAll,
              onRemove: _handleRemove,
              onWeightChanged: _handleWeightChanged,
              onChanged: () => setState(() {}),
              onModeChanged: _handleModeChanged,
              onTeamCountChanged: _handleTeamCountChanged,
            );

            final showTeamPanel =
                _mode == AppMode.teams && _teamManager.totalMembers > 0;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Expanded(child: wheelWidget),
                              if (showTeamPanel)
                                SizedBox(
                                  height: 200,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 8, 16),
                                    child: TeamPanel(teamManager: _teamManager),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 360,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                            child: panelWidget,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        flex: showTeamPanel ? 3 : 5,
                        child: wheelWidget,
                      ),
                      if (showTeamPanel)
                        SizedBox(
                          height: 130,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: TeamPanel(teamManager: _teamManager),
                          ),
                        ),
                      Expanded(
                        flex: showTeamPanel ? 4 : 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: panelWidget,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
