import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_model.dart';
import 'models/game_mode.dart';
import 'widgets/game_board.dart';
import 'widgets/piece_preview.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/sound_service.dart';
import 'screens/mode_selection_screen.dart';
import 'models/block_skin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/player_profile.dart';
import 'package:provider/provider.dart';
import 'screens/stats_screen.dart';
import 'services/player_profile_service.dart';

final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(AppTheme.lightTheme);
final ValueNotifier<BlockSkin> blockSkinNotifier = ValueNotifier(BlockSkin.flat);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme') ?? 'pastel';
  final skin = prefs.getString('skin') ?? 'flat';
  themeNotifier.value = _getThemeData(theme);
  blockSkinNotifier.value = _getBlockSkin(skin);
  runApp(
    ChangeNotifierProvider(
      create: (context) => PreferencesService(),
      child: const MyApp(),
    ),
  );
}

ThemeData _getThemeData(String theme) {
  switch (theme) {
    case 'pastel':
      return AppTheme.lightTheme;
    case 'retroNeon':
      return AppTheme.darkTheme;
    case 'monochrome':
      return AppTheme.monochromeTheme;
    case 'cyberpunk':
      return AppTheme.cyberpunkTheme;
    default:
      return AppTheme.lightTheme;
  }
}

BlockSkin _getBlockSkin(String skin) {
  switch (skin) {
    case 'flat':
      return BlockSkin.flat;
    case 'glossy':
      return BlockSkin.glossy;
    case 'pixelArt':
      return BlockSkin.pixelArt;
    default:
      return BlockSkin.flat;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Tetras',
          theme: theme,
          home: const ModeSelectionScreen(),
          routes: {
            '/stats': (context) => const StatsScreen(),
          },
        );
      },
    );
  }
}

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
    if (widget.gameMode != GameMode.zen) {
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_gameModel.isPlaying) {
          setState(() {
            _gameModel.moveDown();
          });
        }
        if (_gameModel.isGameOver) {
          _updateHighScore();
          _profileService.addXp(_profile, _gameModel.score);
          _preferencesService.incrementLinesCleared(_gameModel.linesCleared);
          _preferencesService.updateTotalTimePlayed(const Duration(milliseconds: 500));
        }
      });
    }
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
          widget.gameMode.toString().split('.').last, _highScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tetras',
          style: GoogleFonts.pressStart2p(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (_gameModel.isPlaying) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            setState(() => _gameModel.moveLeft());
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            setState(() => _gameModel.moveRight());
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            setState(() {
              _gameModel.rotate();
              _soundService.playRotateSound();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            setState(() {
              _gameModel.moveDown();
              _soundService.playDropSound();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
            setState(() {
              _gameModel.hardDrop();
              _controller.forward();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.keyC)) {
            setState(() => _gameModel.hold());
          }
        }
        if (event.isKeyPressed(LogicalKeyboardKey.keyP)) {
          setState(() => _gameModel.togglePause());
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<BlockSkin>(
                  valueListenable: blockSkinNotifier,
                  builder: (context, blockSkin, child) {
                    return AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Game Over',
                          style: TextStyle(fontSize: 48, color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _gameModel.restart();
                            });
                          },
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                if (!_gameModel.isPlaying && !_gameModel.isGameOver)
                  const Center(
                    child: Text(
                      'Paused',
                      style: TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => setState(() => _gameModel.moveLeft()),
                icon: const Icon(Icons.arrow_left),
              ),
              IconButton(
                onPressed: () => setState(() => _gameModel.moveRight()),
                icon: const Icon(Icons.arrow_right),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _gameModel.rotate();
                  _soundService.playRotateSound();
                }),
                icon: const Icon(Icons.rotate_right),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _gameModel.moveDown();
                  _soundService.playDropSound();
                }),
                icon: const Icon(Icons.arrow_downward),
              ),
              IconButton(
                onPressed: () => setState(() => _gameModel.hold()),
                icon: const Text('Hold'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (_gameModel.isPlaying) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            setState(() => _gameModel.moveLeft());
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            setState(() => _gameModel.moveRight());
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            setState(() {
              _gameModel.rotate();
              _soundService.playRotateSound();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            setState(() {
              _gameModel.moveDown();
              _soundService.playDropSound();
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
            setState(() {
              _gameModel.hardDrop();
              _controller.forward(from: 0);
            });
          } else if (event.isKeyPressed(LogicalKeyboardKey.keyC)) {
            setState(() => _gameModel.hold());
          }
        }
        if (event.isKeyPressed(LogicalKeyboardKey.keyP)) {
          setState(() => _gameModel.togglePause());
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<BlockSkin>(
                  valueListenable: blockSkinNotifier,
                  builder: (context, blockSkin, child) {
                    return AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Game Over',
                          style: TextStyle(fontSize: 48, color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _gameModel.restart();
                            });
                          },
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                if (!_gameModel.isPlaying && !_gameModel.isGameOver)
                  const Center(
                    child: Text(
                      'Paused',
                      style: TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: Column(
              children: [
                Text('Score: ${_gameModel.score}'),
                Text('High Score: $_highScore'),
                Text('Level: ${_gameModel.level}'),
                const SizedBox(height: 20),
                const Text('Next Piece:'),
                PiecePreview(piece: _gameModel.nextPiece),
                const SizedBox(height: 20),
                const Text('Hold Piece:'),
                PiecePreview(piece: _gameModel.holdPiece),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
