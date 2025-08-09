import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_model.dart';
import 'widgets/game_board.dart';
import 'widgets/piece_preview.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/sound_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetras',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameModel _gameModel = GameModel();
  final PreferencesService _preferencesService = PreferencesService();
  final SoundService _soundService = SoundService();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_gameModel.isPlaying) {
        setState(() {
          _gameModel.moveDown();
        });
      }
      if (_gameModel.isGameOver) {
        _updateHighScore();
      }
    });
  }

  void _loadHighScore() async {
    _highScore = await _preferencesService.getHighScore();
    setState(() {});
  }

  void _updateHighScore() {
    if (_gameModel.score > _highScore) {
      _highScore = _gameModel.score;
      _preferencesService.setHighScore(_highScore);
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
            // TODO: Implement hard drop
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
                GameBoard(gameModel: _gameModel),
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
            // TODO: Implement hard drop
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
                GameBoard(gameModel: _gameModel),
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
