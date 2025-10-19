import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

import '../main.dart';
import '../models/block_skin.dart';
import '../models/difficulty_tier.dart';
import '../models/game_mode.dart';
import '../models/game_model.dart';
import '../models/player_profile.dart';
import '../services/player_profile_service.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_preview.dart';
import '../widgets/particle_background.dart';
import '../widgets/glass_button.dart';

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
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  late AnimationController _levelAnimationController;
  late Animation<double> _levelAnimation;
  late AnimationController _comboAnimationController;
  late Animation<double> _comboAnimation;
  late ConfettiController _confettiController;
  late ConfettiController _levelUpConfettiController;
  Timer? _gameTimer;
  int _combo = 0;
  int _currentGameSpeed = 500; // Track current game speed
  bool _showRotationLimitWarning = false; // Show warning when rotation limit reached
  bool _showPreviewRemovedWarning = false; // Show warning when preview is removed
  DifficultyTier? _lastDifficultyTier; // Track tier changes

  @override
  void initState() {
    super.initState();
    _gameModel = GameModel(gameMode: widget.gameMode);
    _loadProfile();
    _loadHighScore();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );

    _levelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _levelAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _levelAnimationController, curve: Curves.elasticOut),
    );

    _comboAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _comboAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _comboAnimationController, curve: Curves.easeOut),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _levelUpConfettiController = ConfettiController(duration: const Duration(seconds: 2));

    _lastDifficultyTier = _gameModel.currentDifficultyTier;

    if (widget.gameMode != GameMode.zen) {
      _currentGameSpeed = calculateGameSpeed(_gameModel.level);
      _startGameTimer();
    }
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(Duration(milliseconds: _currentGameSpeed), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_gameModel.isPlaying) {
          final linesClearedBefore = _gameModel.linesClearedInLastMove;
          final levelCompletedBefore = _gameModel.levelCompletedInLastMove;

          setState(() {
            _gameModel.moveDown();
          });

          if (_gameModel.linesClearedInLastMove && !linesClearedBefore) {
            _combo++;
            _handleLineClear();
          }

          if (_gameModel.levelCompletedInLastMove && !levelCompletedBefore) {
            _handleLevelUp();
            // Update game speed for new level
            _updateGameSpeed();
            // Check for tier change
            _checkTierChange();
          }

          _gameModel.resetMoveFlags();
        }
        if (_gameModel.isGameOver) {
          _updateHighScore();
          _profileService.addXp(_profile, _gameModel.score);

          // Record full game session with all statistics
          final sessionDuration = _gameModel.sessionStartTime != null
              ? DateTime.now().difference(_gameModel.sessionStartTime!)
              : Duration.zero;

          _preferencesService.recordGameSession(
            mode: widget.gameMode.toString().split('.').last,
            score: _gameModel.score,
            level: _gameModel.level,
            linesCleared: _gameModel.linesCleared,
            blocksDropped: _gameModel.sessionBlocksDropped,
            timePlayed: sessionDuration,
            perfectClears: _gameModel.sessionPerfectClears,
            maxCombo: _gameModel.sessionMaxCombo,
          );
        }
      });
  }

  void _updateGameSpeed() {
    final newSpeed = calculateGameSpeed(_gameModel.level);
    if (newSpeed != _currentGameSpeed) {
      _currentGameSpeed = newSpeed;
      // Restart timer with new speed
      if (widget.gameMode != GameMode.zen && !_gameModel.isGameOver) {
        _startGameTimer();
      }
    }
  }

  void _checkTierChange() {
    final currentTier = _gameModel.currentDifficultyTier;
    if (_lastDifficultyTier != currentTier) {
      _lastDifficultyTier = currentTier;
      // Show tier change celebration
      _levelUpConfettiController.play();

      // Check if preview should be hidden now
      if (!_gameModel.shouldShowNextPiece && !_showPreviewRemovedWarning) {
        _showPreviewRemovedWarning = true;
        _showTierChangeNotification('Preview removed! Expert mode activated.');
      } else if (currentTier == DifficultyTier.hard) {
        _showTierChangeNotification('Garbage rows incoming! Hard mode activated.');
      } else if (currentTier == DifficultyTier.insane) {
        _showTierChangeNotification('Rotation limited! Insane mode activated.');
      }
    }
  }

  void _showTierChangeNotification(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shakeController.dispose();
    _scoreAnimationController.dispose();
    _levelAnimationController.dispose();
    _comboAnimationController.dispose();
    _confettiController.dispose();
    _levelUpConfettiController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _loadProfile() async {
    _profile = await _profileService.getProfile();
    if (mounted) {
      setState(() {});
    }
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
    if (mounted) {
      setState(() {});
    }
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

  void _handleLineClear() {
    _soundService.playLineClearSound();
    _confettiController.play();
    _scoreAnimationController.forward().then((_) {
      _scoreAnimationController.reverse();
    });
    _comboAnimationController.forward().then((_) {
      _comboAnimationController.reverse();
    });
    _shakeController.forward();
  }

  void _handleLevelUp() {
    _levelUpConfettiController.play();
    _levelAnimationController.forward().then((_) {
      _levelAnimationController.reverse();
    });
  }

  void _handleKeyPress(LogicalKeyboardKey key) {
    final linesClearedBefore = _gameModel.linesClearedInLastMove;
    final levelCompletedBefore = _gameModel.levelCompletedInLastMove;

    if (_gameModel.isPlaying) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        setState(() => _gameModel.moveLeft());
      } else if (key == LogicalKeyboardKey.arrowRight) {
        setState(() => _gameModel.moveRight());
      } else if (key == LogicalKeyboardKey.arrowUp) {
        if (_gameModel.hasReachedRotationLimit) {
          // Show warning
          setState(() {
            _showRotationLimitWarning = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showRotationLimitWarning = false;
              });
            }
          });
        } else {
          setState(() {
            _gameModel.rotate();
            _soundService.playRotateSound();
          });
        }
      } else if (key == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _gameModel.moveDown();
          _soundService.playDropSound();
        });
      } else if (key == LogicalKeyboardKey.space) {
        setState(() {
          _gameModel.hardDrop();
          _shakeController.forward();
        });
        _combo = 0; // Reset combo on hard drop
      } else if (key == LogicalKeyboardKey.keyC) {
        setState(() => _gameModel.hold());
      }
    }
    if (key == LogicalKeyboardKey.keyP) {
      setState(() => _gameModel.togglePause());
    }

    if (_gameModel.linesClearedInLastMove && !linesClearedBefore) {
      _combo++;
      _handleLineClear();
    }

    if (_gameModel.levelCompletedInLastMove && !levelCompletedBefore) {
      _handleLevelUp();
    }

    _gameModel.resetMoveFlags();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: currentThemeNameNotifier,
      builder: (context, themeName, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Particle background
              const ParticleBackground(),

              // Game content
              KeyboardListener(
                focusNode: FocusNode(),
                autofocus: true,
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    _handleKeyPress(event.logicalKey);
                  }
                },
                child: Stack(
                  children: [
                    // SafeArea wrapper for game content only
                    SafeArea(
                      child: Stack(
                        children: [
                          // Main game area - "Vertical Core" Mobile Layout
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OrientationBuilder(
                              builder: (context, orientation) {
                                if (orientation == Orientation.portrait) {
                                  return _buildPortraitLayout(theme);
                                } else {
                                  return _buildLandscapeLayout(theme);
                                }
                              },
                            ),
                          ),

                          // Confetti effects
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
                              colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                      ),
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
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                      ),

                      // Rotation limit warning
                      if (_showRotationLimitWarning)
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.25,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.block, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ROTATION LIMIT REACHED!',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Combo indicator
                      if (_combo > 1 && _gameModel.isPlaying)
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.3,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ScaleTransition(
                              scale: _comboAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'COMBO x$_combo',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),

                    // Full screen overlays - OUTSIDE SafeArea for true full screen
                    if (_gameModel.isGameOver)
                      Positioned.fill(
                        child: _buildGameOverOverlay(theme),
                      ),
                    if (!_gameModel.isPlaying && !_gameModel.isGameOver)
                      Positioned.fill(
                        child: _buildPausedOverlay(theme),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameOverOverlay(ThemeData theme) {
    final isNewHighScore = _gameModel.score > _highScore;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Dramatic blur and darken effect - FULL SCREEN
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 15 * value,
                  sigmaY: 15 * value,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        theme.colorScheme.error.withValues(alpha: 0.15 * value),
                        Colors.black.withValues(alpha: 0.9 * value),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Animated "shattered" effect particles
            ...List.generate(20, (index) {
              final angle = (index * 18.0) * (3.14159 / 180);
              final distance = 100 + (index * 30);
              final xOffset = distance * cos(angle) * value;
              final yOffset = distance * sin(angle) * value;

              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + xOffset - 10,
                top: MediaQuery.of(context).size.height / 2 + yOffset - 10,
                child: Opacity(
                  opacity: (1.0 - value) * 0.6,
                  child: Transform.rotate(
                    angle: value * 6.28 + index,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Main content with dramatic entrance
            Center(
              child: Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Transform.rotate(
                  angle: (1.0 - value) * 0.1,
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dramatic skull/sad icon with shake effect
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: -0.05, end: 0.05),
                              curve: Curves.easeInOut,
                              builder: (context, shakeValue, child) {
                                return Transform.rotate(
                                  angle: shakeValue,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          theme.colorScheme.error,
                                          theme.colorScheme.error.withValues(alpha: 0.6),
                                          Colors.red.shade900,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.error.withValues(alpha: 0.8),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: Colors.red.withValues(alpha: 0.5),
                                          blurRadius: 60,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              onEnd: () {
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: 24),

                            // Dramatic "GAME OVER" text with glitch effect
                            Stack(
                              children: [
                                // Red glitch layer
                                Transform.translate(
                                  offset: Offset(-2 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      'GAME OVER',
                                      style: theme.textTheme.headlineLarge?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 52,
                                        letterSpacing: 6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Blue glitch layer
                                Transform.translate(
                                  offset: Offset(2 * (1 - value), 0),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: Text(
                                      'GAME OVER',
                                      style: theme.textTheme.headlineLarge?.copyWith(
                                        color: Colors.cyan,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 52,
                                        letterSpacing: 6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Main text
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.white,
                                        theme.colorScheme.error,
                                        Colors.red.shade900,
                                        theme.colorScheme.error,
                                        Colors.white,
                                      ],
                                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    'GAME OVER',
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 52,
                                      letterSpacing: 6,
                                      shadows: [
                                        Shadow(
                                          color: theme.colorScheme.error,
                                          blurRadius: 30,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Enhanced stats card with staggered animation
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, statsValue, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - statsValue)),
                                  child: Opacity(
                                    opacity: statsValue.clamp(0.0, 1.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.surface.withValues(alpha: 0.4),
                                            theme.colorScheme.surface.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: isNewHighScore
                                              ? theme.colorScheme.tertiary.withValues(alpha: 0.5)
                                              : theme.colorScheme.error.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isNewHighScore
                                                ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
                                                : theme.colorScheme.error.withValues(alpha: 0.2),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          _buildEnhancedOverlayStat(
                                            theme,
                                            'SCORE',
                                            _gameModel.score.toString(),
                                            Icons.emoji_events,
                                            isNewHighScore
                                                ? theme.colorScheme.tertiary
                                                : theme.colorScheme.primary,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildEnhancedOverlayStat(
                                            theme,
                                            'LINES',
                                            _gameModel.linesCleared.toString(),
                                            Icons.horizontal_rule,
                                            theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildEnhancedOverlayStat(
                                            theme,
                                            'LEVEL',
                                            _gameModel.level.toString(),
                                            Icons.trending_up,
                                            theme.colorScheme.primary,
                                          ),
                                          if (isNewHighScore) ...[
                                            const SizedBox(height: 20),
                                            TweenAnimationBuilder<double>(
                                              duration: const Duration(milliseconds: 1000),
                                              tween: Tween(begin: 0.9, end: 1.1),
                                              curve: Curves.easeInOut,
                                              builder: (context, badgeValue, child) {
                                                return Transform.scale(
                                                  scale: badgeValue,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          theme.colorScheme.tertiary,
                                                          theme.colorScheme.tertiary.withValues(alpha: 0.7),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(30),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: theme.colorScheme.tertiary.withValues(alpha: 0.6),
                                                          blurRadius: 20 * badgeValue,
                                                          spreadRadius: 5 * badgeValue,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.stars_rounded,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'NEW HIGH SCORE!',
                                                          style: theme.textTheme.titleMedium?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              onEnd: () {
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Animated action buttons
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, btnValue, child) {
                                return Transform.translate(
                                  offset: Offset(0, 40 * (1 - btnValue)),
                                  child: Opacity(
                                    opacity: btnValue.clamp(0.0, 1.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                                  blurRadius: 25,
                                                  spreadRadius: 3,
                                                ),
                                              ],
                                            ),
                                            child: GlassButton(
                                              text: 'RETRY',
                                              onPressed: () {
                                                setState(() {
                                                  _gameModel.restart();
                                                  _combo = 0;
                                                });
                                              },
                                              icon: Icons.refresh,
                                              isPrimary: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: SizedBox(
                                            height: 60,
                                            child: GlassButton(
                                              text: 'EXIT',
                                              onPressed: () => Navigator.of(context).pop(),
                                              icon: Icons.exit_to_app,
                                              isPrimary: false,
                                              isOutlined: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPausedOverlay(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            // Animated blur background - FULL SCREEN
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10 * value,
                  sigmaY: 10 * value,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7 * value),
                  ),
                ),
              ),
            ),

            // Animated floating tetromino pieces in background
            ...List.generate(8, (index) {
              final offset = (index * 0.3) % 1.0;
              return Positioned(
                left: (50 + index * 80) % MediaQuery.of(context).size.width,
                top: -100 + (MediaQuery.of(context).size.height * offset * value),
                child: Opacity(
                  opacity: 0.1 * value,
                  child: Transform.rotate(
                    angle: (index * 0.5) + (value * 0.2),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary,
                        ][index % 3],
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                              theme.colorScheme.tertiary,
                            ][index % 3].withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Main content with slide-in animation
            Center(
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pulsing animated icon
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.95, end: 1.05),
                            curve: Curves.easeInOut,
                            builder: (context, pulseValue, child) {
                              return Transform.scale(
                                scale: pulseValue,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                        theme.colorScheme.tertiary,
                                      ],
                                      stops: const [0.0, 0.6, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                        blurRadius: 30 * pulseValue,
                                        spreadRadius: 10 * pulseValue,
                                      ),
                                      BoxShadow(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                        blurRadius: 50 * pulseValue,
                                        spreadRadius: 15 * pulseValue,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.pause,
                                    size: 56,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            onEnd: () {
                              // Loop the animation
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 24),

                          // Animated gradient text with shimmer effect
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                  theme.colorScheme.tertiary,
                                  theme.colorScheme.primary,
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            child: Text(
                              'PAUSED',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                letterSpacing: 4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Enhanced stats card with animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, cardValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - cardValue)),
                                child: Opacity(
                                  opacity: cardValue.clamp(0.0, 1.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          theme.colorScheme.surface.withValues(alpha: 0.3),
                                          theme.colorScheme.surface.withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        _buildEnhancedOverlayStat(
                                          theme,
                                          'SCORE',
                                          _gameModel.score.toString(),
                                          Icons.emoji_events,
                                          theme.colorScheme.tertiary,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildEnhancedOverlayStat(
                                          theme,
                                          'LEVEL',
                                          _gameModel.level.toString(),
                                          Icons.trending_up,
                                          theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Animated buttons
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, btnValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - btnValue)),
                                child: Opacity(
                                  opacity: btnValue.clamp(0.0, 1.0),
                                  child: Column(
                                    children: [
                                      // Resume button with glow
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: GlassButton(
                                            text: 'RESUME',
                                            onPressed: () {
                                              setState(() => _gameModel.togglePause());
                                            },
                                            icon: Icons.play_arrow,
                                            isPrimary: true,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Exit button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: GlassButton(
                                          text: 'EXIT',
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: Icons.exit_to_app,
                                          isPrimary: false,
                                          isOutlined: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedOverlayStat(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // CENTERED ZEN LAYOUT WIDGETS

  // PORTRAIT LAYOUT
  Widget _buildPortraitLayout(ThemeData theme) {
    return Column(
      children: [
        // Top HUD Bar (50px)
        _buildTopHUD(theme),

        const SizedBox(height: 8),

        // Game board area with floating overlays (reduced to ~55-60% height)
        Expanded(
          flex: 7,
          child: _buildBoardWithOverlays(theme),
        ),

        const SizedBox(height: 4),

        // Progress bar
        _buildProgressBar(theme),

        const SizedBox(height: 8),

        // Bottom D-pad controls (95px - larger)
        _buildBottomDPadControls(theme),

        const SizedBox(height: 4),
      ],
    );
  }

  // LANDSCAPE LAYOUT
  Widget _buildLandscapeLayout(ThemeData theme) {
    return Column(
      children: [
        // Top bar with stats + previews (50-60px)
        _buildTopBarLandscape(theme),

        const SizedBox(height: 4),

        // Progress bar
        _buildProgressBar(theme),

        const SizedBox(height: 8),

        // Centered game board
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 10 / 20,
              child: _buildGameBoardWidget(theme),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Bottom D-pad controls
        _buildBottomDPadControls(theme),
      ],
    );
  }

  // TOP HUD BAR (Portrait) - Horizontal stats bar with glass effect
  Widget _buildTopHUD(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.arrow_back, color: theme.colorScheme.primary, size: 18),
                ),
              ),

              const SizedBox(width: 12),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompactStat(theme, 'SCORE', _gameModel.score.toString(), _scoreAnimation, true),
                    _buildVerticalDivider(theme),
                    _buildCompactStat(theme, 'LVL', _gameModel.level.toString(), _levelAnimation, false),
                    _buildVerticalDivider(theme),
                    _buildDifficultyBadge(theme),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Pause button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _gameModel.togglePause());
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _gameModel.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TOP BAR LANDSCAPE - Combined stats + previews
  Widget _buildTopBarLandscape(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.arrow_back, color: theme.colorScheme.primary, size: 20),
                ),
              ),

              const SizedBox(width: 16),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompactStat(theme, 'SCORE', _gameModel.score.toString(), _scoreAnimation, true),
                    _buildVerticalDivider(theme),
                    _buildCompactStat(theme, 'LINES', _gameModel.linesCleared.toString(), null, false),
                    _buildVerticalDivider(theme),
                    _buildCompactStat(theme, 'LVL', _gameModel.level.toString(), _levelAnimation, false),
                    _buildVerticalDivider(theme),
                    _buildDifficultyBadge(theme),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Next/Hold previews (compact) - only show if not hidden by difficulty
              if (_gameModel.shouldShowNextPiece)
                Row(
                  children: [
                    _buildSmallPreview(theme, 'NEXT', _gameModel.nextPiece, theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    _buildSmallPreview(theme, 'HOLD', _gameModel.heldPiece, theme.colorScheme.secondary),
                  ],
                ),

              const SizedBox(width: 16),

              // Pause button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _gameModel.togglePause());
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _gameModel.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COMPACT STAT (for HUD bars)
  Widget _buildCompactStat(ThemeData theme, String label, String value, Animation<double>? animation, bool isPrimary) {
    final color = isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondary;

    Widget valueWidget = Text(
      value,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        height: 1.1,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (animation != null) {
      valueWidget = ScaleTransition(scale: animation, child: valueWidget);
    }

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.colorScheme.onSurface.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // SMALL PREVIEW (for landscape top bar)
  Widget _buildSmallPreview(ThemeData theme, String label, dynamic piece, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.15),
                accentColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: PiecePreview(piece: piece),
            ),
          ),
        ),
      ],
    );
  }

  // BOARD WITH OVERLAYS (Portrait) - Stack with board + floating previews
  Widget _buildBoardWithOverlays(ThemeData theme) {
    return Stack(
      children: [
        // Centered game board
        Center(
          child: AspectRatio(
            aspectRatio: 10 / 20,
            child: _buildGameBoardWidget(theme),
          ),
        ),

        // Floating preview panels overlay (right side)
        _buildFloatingPreviewsOverlay(theme),
      ],
    );
  }

  // GAME BOARD WIDGET - Board with gradient background + neon glow
  Widget _buildGameBoardWidget(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Multi-layer neon glow effect
          boxShadow: [
            // Inner glow
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            // Middle glow
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 35,
              spreadRadius: 3,
            ),
            // Outer glow
            BoxShadow(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.25),
              blurRadius: 50,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              // Modern gradient background with subtle texture
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1e1e2e), // dark purple-gray
                  Color(0xFF181825), // darker purple-gray
                  Color(0xFF11111b), // darkest purple-gray
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // Inner shadow effect for depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Enhanced grid background with glow
                CustomPaint(
                  size: Size.infinite,
                  painter: GameBoardBackgroundPainter(
                    gridColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    glowColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                // Game board
                ValueListenableBuilder<BlockSkin>(
                  valueListenable: blockSkinNotifier,
                  builder: (context, blockSkin, child) {
                    return GameBoard(
                      gameModel: _gameModel,
                      blockSkin: blockSkin,
                      onRowClearAnimationStart: () {
                        // Trigger confetti when row clearing animation starts
                        _confettiController.play();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FLOATING PREVIEWS OVERLAY (Portrait) - Next/Hold/Music/Settings on right
  Widget _buildFloatingPreviewsOverlay(ThemeData theme) {
    return Positioned(
      top: 20,
      right: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Next piece - only show if allowed by difficulty
                if (_gameModel.shouldShowNextPiece) ...[
                  Text(
                    'NEXT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: Center(
                          child: PiecePreview(piece: _gameModel.nextPiece),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  // Show "Hidden" indicator when preview is removed
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.error.withValues(alpha: 0.2),
                          theme.colorScheme.error.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.visibility_off,
                        color: theme.colorScheme.error.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 10),

                // Hold piece
                Text(
                  'HOLD',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withValues(alpha: 0.2),
                        theme.colorScheme.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                        child: PiecePreview(piece: _gameModel.heldPiece),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Music toggle button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Toggle music
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.tertiary.withValues(alpha: 0.3),
                          theme.colorScheme.tertiary.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.music_note, color: theme.colorScheme.tertiary, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PROGRESS BAR - Lines until next level
  Widget _buildProgressBar(ThemeData theme) {
    final linesInCurrentLevel = _gameModel.linesClearedInLevel;
    final linesNeeded = _gameModel.linesNeededForNextLevel;
    final progress = linesNeeded > 0 ? (linesInCurrentLevel / linesNeeded).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'LINES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$linesInCurrentLevel/$linesNeeded',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM D-PAD CONTROLS - D-pad style + Actions
  Widget _buildBottomDPadControls(ThemeData theme) {
    return SizedBox(
      height: 95,
      child: Row(
        children: [
          // Left: D-Pad arrangement
          Expanded(
            child: Stack(
              children: [
                // Down button (bottom center)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildCircularButton(
                      theme,
                      Icons.arrow_downward,
                      () => setState(() => _gameModel.moveDown()),
                      false,
                    ),
                  ),
                ),
                // Left and Right buttons (top)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(
                        theme,
                        Icons.arrow_back,
                        () => setState(() => _gameModel.moveLeft()),
                        false,
                      ),
                      _buildCircularButton(
                        theme,
                        Icons.arrow_forward,
                        () => setState(() => _gameModel.moveRight()),
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right: Action buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularButton(
                  theme,
                  Icons.rotate_right,
                  () => setState(() => _gameModel.rotate()),
                  true,
                ),
                _buildCircularButton(
                  theme,
                  Icons.keyboard_double_arrow_down,
                  () => setState(() => _gameModel.hardDrop()),
                  true,
                ),
                _buildCircularButton(
                  theme,
                  Icons.swap_horiz,
                  () => setState(() => _gameModel.hold()),
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CIRCULAR BUTTON - Reusable control button with haptic feedback
  Widget _buildCircularButton(ThemeData theme, IconData icon, VoidCallback onPressed, bool isPrimary) {
    final color = isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondary;

    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth * 0.13).clamp(52.0, 68.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  // DIFFICULTY BADGE - Shows current difficulty tier
  Widget _buildDifficultyBadge(ThemeData theme) {
    final tier = _gameModel.currentDifficultyTier;
    final config = _gameModel.difficultyConfig;

    Color badgeColor;
    switch (tier) {
      case DifficultyTier.easy:
        badgeColor = Colors.green;
        break;
      case DifficultyTier.medium:
        badgeColor = Colors.blue;
        break;
      case DifficultyTier.hard:
        badgeColor = Colors.orange;
        break;
      case DifficultyTier.expert:
        badgeColor = Colors.red;
        break;
      case DifficultyTier.insane:
        badgeColor = Colors.purple;
        break;
    }

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: badgeColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          config.displayName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: badgeColor,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}

// Custom painter for game board background with grid and subtle glow
class GameBoardBackgroundPainter extends CustomPainter {
  final Color gridColor;
  final Color glowColor;

  GameBoardBackgroundPainter({
    required this.gridColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 20;
    const cols = 10;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // Draw radial glow from center
    final radialGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        glowColor.withValues(alpha: 0.15),
        glowColor.withValues(alpha: 0.05),
        glowColor.withValues(alpha: 0.0),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()..shader = radialGradient.createShader(rect),
    );

    // Draw enhanced grid lines with glow
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 1; i < cols; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal lines with alternating emphasis
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      // Every 5th line is slightly brighter
      if (i % 5 == 0) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          Paint()
            ..color = gridColor.withValues(alpha: gridColor.a * 1.5)
            ..strokeWidth = 1.0,
        );
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Add subtle dot pattern at intersections for extra style
    final dotPaint = Paint()
      ..color = gridColor.withValues(alpha: gridColor.a * 0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i <= cols; i++) {
      for (int j = 0; j <= rows; j++) {
        if (i % 2 == 0 && j % 2 == 0) {
          canvas.drawCircle(
            Offset(i * cellWidth, j * cellHeight),
            1,
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
