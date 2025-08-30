import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

import '../main.dart';
import '../models/block_skin.dart';
import '../models/game_mode.dart';
import '../models/game_model.dart';
import '../models/player_profile.dart';
import '../services/player_profile_service.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/particle_background.dart';
import '../widgets/piece_preview.dart';

class GameScreen extends StatefulWidget {
  final GameMode gameMode;

  const GameScreen({super.key, this.gameMode = GameMode.classic});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final GameModel _gameModel;
  final PreferencesService _preferencesService = PreferencesService();
  final SoundService _soundService = SoundService();
  final PlayerProfileService _profileService = PlayerProfileService();
  late PlayerProfile _profile;
  int _highScore = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _buttonPressController;
  late Animation<double> _buttonPressAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  late AnimationController _levelAnimationController;
  late Animation<double> _levelAnimation;
  late ConfettiController _confettiController;
  late ConfettiController _levelUpConfettiController;

  @override
  void initState() {
    super.initState();
    _gameModel = GameModel(gameMode: widget.gameMode);
    _loadProfile();
    _loadHighScore();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 10).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
    
    _buttonPressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonPressAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeInOut),
    );
    
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );
    
    _levelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _levelAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _levelAnimationController, curve: Curves.elasticOut),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _levelUpConfettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    if (widget.gameMode != GameMode.zen) {
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_gameModel.isPlaying) {
          // Store previous state to check for changes
          final linesClearedBefore = _gameModel.linesClearedInLastMove;
          final levelCompletedBefore = _gameModel.levelCompletedInLastMove;
          
          setState(() {
            _gameModel.moveDown();
          });
          
          // Check for line clears and level ups after the move
          if (_gameModel.linesClearedInLastMove && !linesClearedBefore) {
            _soundService.playLineClearSound();
            _confettiController.play();
            _scoreAnimationController.forward().then((_) {
              _scoreAnimationController.reverse();
            });
          }
          
          if (_gameModel.levelCompletedInLastMove && !levelCompletedBefore) {
            _levelUpConfettiController.play();
            _levelAnimationController.forward().then((_) {
              _levelAnimationController.reverse();
            });
          }
          
          // Reset the flags after checking them
          _gameModel.resetMoveFlags();
        }
        if (_gameModel.isGameOver) {
          _updateHighScore();
          _profileService.addXp(_profile, _gameModel.score);
          _preferencesService.incrementLinesCleared(_gameModel.linesCleared);
          _preferencesService.incrementBlocksDropped();
          _preferencesService.updateTotalTimePlayed(
            const Duration(milliseconds: 500),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonPressController.dispose();
    _scoreAnimationController.dispose();
    _levelAnimationController.dispose();
    _confettiController.dispose();
    _levelUpConfettiController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _loadProfile() async {
    _profile = await _profileService.getProfile();
    setState(() {});
  }

  void _loadHighScore() {
    switch (widget.gameMode) {
      case GameMode.classic:
        _highScore = _preferencesService.highScoreClassic;
        break;
      case GameMode.sprint:
        _highScore = _preferencesService.highScoreSprint;
        break;
      case GameMode.marathon:
        _highScore = _preferencesService.highScoreMarathon;
        break;
      case GameMode.zen:
        _highScore = _preferencesService.highScoreZen;
        break;
    }
    setState(() {});
  }

  void _updateHighScore() {
    if (_gameModel.score > _highScore) {
      _highScore = _gameModel.score;
      _preferencesService.setHighScore(
        widget.gameMode.toString().split('.').last,
        _highScore,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
          // Store previous state to check for changes
          final linesClearedBefore = _gameModel.linesClearedInLastMove;
          final levelCompletedBefore = _gameModel.levelCompletedInLastMove;
          
          if (_gameModel.isPlaying) {
            if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.arrowLeft,
            )) {
              setState(() => _gameModel.moveLeft());
            } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.arrowRight,
            )) {
              setState(() => _gameModel.moveRight());
            } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.arrowUp,
            )) {
              setState(() {
                _gameModel.rotate();
                _soundService.playRotateSound();
              });
            } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.arrowDown,
            )) {
              setState(() {
                _gameModel.moveDown();
                _soundService.playDropSound();
              });
            } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.space,
            )) {
              setState(() {
                _gameModel.hardDrop();
                _controller.forward(from: 0);
              });
            } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.keyC,
            )) {
              setState(() => _gameModel.hold());
            }
          }
          if (HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.keyP,
          )) {
            setState(() => _gameModel.togglePause());
          }
          
          // Check for line clears and level ups after the move
          if (_gameModel.linesClearedInLastMove && !linesClearedBefore) {
            _soundService.playLineClearSound();
            _confettiController.play();
            _scoreAnimationController.forward().then((_) {
              _scoreAnimationController.reverse();
            });
          }
          
          if (_gameModel.levelCompletedInLastMove && !levelCompletedBefore) {
            _levelUpConfettiController.play();
            _levelAnimationController.forward().then((_) {
              _levelAnimationController.reverse();
            });
          }
          
          // Reset the flags after checking them
          _gameModel.resetMoveFlags();
        },
        child: Stack(
          children: [
            // Line clear confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.01,
                numberOfParticles: 50,
                maxBlastForce: 100,
                minBlastForce: 80,
                gravity: 0.3,
              ),
            ),
            // Level up confetti
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _levelUpConfettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.01,
                numberOfParticles: 100,
                maxBlastForce: 100,
                minBlastForce: 80,
                gravity: 0.3,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Top info bar - fixed height
                        SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              // Stats take more space
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: _buildStatColumn(
                                        'SCORE',
                                        _gameModel.score.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatColumn(
                                        'LINES',
                                        _gameModel.linesCleared.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildStatColumn(
                                        'LEVEL',
                                        _gameModel.level.toString(),
                                        isLevel: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Hold piece
                              _buildPiecePreview('HOLD', _gameModel.heldPiece),
                              const SizedBox(width: 8),
                              // Next piece
                              _buildPiecePreview('NEXT', _gameModel.nextPiece),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Game board area - takes remaining space minus controls
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, gameConstraints) {
                                // Calculate proper game board size
                                final aspectRatio = 10.0 / 20.0;
                                double boardWidth, boardHeight;

                                if (gameConstraints.maxWidth /
                                        gameConstraints.maxHeight >
                                    aspectRatio) {
                                  boardHeight = gameConstraints.maxHeight;
                                  boardWidth = boardHeight * aspectRatio;
                                } else {
                                  boardWidth = gameConstraints.maxWidth;
                                  boardHeight = boardWidth / aspectRatio;
                                }

                                return Center(
                                  child: Container(
                                    width: boardWidth,
                                    height: boardHeight,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Grid background
                                        CustomPaint(
                                          size: Size(boardWidth, boardHeight),
                                          painter: GridPainter(
                                            gridColor: theme
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                        // Game board
                                        ValueListenableBuilder<BlockSkin>(
                                          valueListenable: blockSkinNotifier,
                                          builder: (context, blockSkin, child) {
                                            return AnimatedBuilder(
                                              animation: _animation,
                                              builder: (context, child) {
                                                return Transform.translate(
                                                  offset: Offset(
                                                    _animation.value,
                                                    0,
                                                  ),
                                                  child: child,
                                                );
                                              },
                                              child: GameBoard(
                                                gameModel: _gameModel,
                                                blockSkin: blockSkin,
                                              ),
                                            );
                                          },
                                        ),
                                        if (_gameModel.isGameOver)
                                          _buildGameOverOverlay(),
                                        if (!_gameModel.isPlaying &&
                                            !_gameModel.isGameOver)
                                          _buildPausedOverlay(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Control buttons - improved UI/UX
                        SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              // Left side - action buttons
                              Expanded(
                                child: Column(
                                  children: [
                                    // Action buttons row
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildActionButton(
                                              Icons.rotate_right,
                                              () => setState(
                                                () => _gameModel.rotate(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildActionButton(
                                              Icons.swap_horiz,
                                              () => setState(
                                                () => _gameModel.hold(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Pause button
                                    Expanded(
                                      child: _buildActionButton(
                                        Icons.pause,
                                        () => setState(
                                          () => _gameModel.togglePause(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Right side - movement controls
                              Expanded(
                                child: Column(
                                  children: [
                                    // Soft drop button
                                    Expanded(
                                      child: _buildMovementButton(
                                        Icons.keyboard_arrow_down,
                                        () => setState(
                                          () => _gameModel.moveDown(),
                                        ),
                                      ),
                                    ),
                                    // Movement buttons row
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildMovementButton(
                                              Icons.keyboard_arrow_left,
                                              () => setState(
                                                () => _gameModel.moveLeft(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildMovementButton(
                                              Icons.keyboard_double_arrow_down,
                                              () => setState(
                                                () => _gameModel.hardDrop(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildMovementButton(
                                              Icons.keyboard_arrow_right,
                                              () => setState(
                                                () => _gameModel.moveRight(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {bool isLevel = false}) {
    final theme = Theme.of(context);
    final isScore = label == 'SCORE';
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 4),
        isScore
            ? ScaleTransition(
                scale: _scoreAnimation,
                child: Text(
                  value,
                  style: GoogleFonts.pressStart2p(
                    color: theme.colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : isLevel
                ? ScaleTransition(
                    scale: _levelAnimation,
                    child: Text(
                      value,
                      style: GoogleFonts.pressStart2p(
                        color: theme.colorScheme.secondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.pressStart2p(
                      color: theme.colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ],
    );
  }

  Widget _buildPiecePreview(String label, dynamic piece) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: PiecePreview(piece: piece),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => _buttonPressController.forward(),
      onTapUp: (_) => _buttonPressController.reverse(),
      onTapCancel: () => _buttonPressController.reverse(),
      child: ScaleTransition(
        scale: _buttonPressAnimation,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, 
              color: theme.colorScheme.primary, 
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementButton(IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => _buttonPressController.forward(),
      onTapUp: (_) => _buttonPressController.reverse(),
      onTapCancel: () => _buttonPressController.reverse(),
      child: ScaleTransition(
        scale: _buttonPressAnimation,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            border: Border.all(
              color: theme.colorScheme.secondary.withOpacity(0.7),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, 
              color: theme.colorScheme.secondary, 
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_very_dissatisfied,
                size: 60,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'GAME OVER',
                style: GoogleFonts.pressStart2p(
                  fontSize: 24,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildGameOverStat('SCORE', _gameModel.score.toString()),
                      const SizedBox(height: 12),
                      _buildGameOverStat('LINES', _gameModel.linesCleared.toString()),
                      const SizedBox(height: 12),
                      _buildGameOverStat('LEVEL', _gameModel.level.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _gameModel.restart();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'PLAY AGAIN',
                      style: GoogleFonts.pressStart2p(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'EXIT',
                      style: GoogleFonts.pressStart2p(
                        color: theme.colorScheme.onSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverStat(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPausedOverlay() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause,
                size: 60,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'PAUSED',
                style: GoogleFonts.pressStart2p(
                  fontSize: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildGameOverStat('SCORE', _gameModel.score.toString()),
                      const SizedBox(height: 12),
                      _buildGameOverStat('LEVEL', _gameModel.level.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Press P to resume',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;

  GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const rows = 20;
    const cols = 10;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // Draw vertical lines
    for (int i = 1; i < cols; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
