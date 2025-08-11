// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../models/block_skin.dart';
// import '../models/game_mode.dart';
// import '../models/game_model.dart';
// import '../models/player_profile.dart';
// import '../services/player_profile_service.dart';
// import '../services/preferences_service.dart';
// import '../services/sound_service.dart';
// import '../widgets/game_board.dart';
// import '../widgets/piece_preview.dart';
// import '../widgets/particle_background.dart';
// import '../main.dart';

// class GameScreen extends StatefulWidget {
//   final GameMode gameMode;

//   const GameScreen({super.key, this.gameMode = GameMode.classic});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   late final GameModel _gameModel;
//   final PreferencesService _preferencesService = PreferencesService();
//   final SoundService _soundService = SoundService();
//   final PlayerProfileService _profileService = PlayerProfileService();
//   late PlayerProfile _profile;
//   int _highScore = 0;
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _gameModel = GameModel(gameMode: widget.gameMode);
//     _loadProfile();
//     _loadHighScore();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 10).animate(_controller)
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           _controller.reverse();
//         }
//       });
//     if (widget.gameMode != GameMode.zen) {
//       Timer.periodic(const Duration(milliseconds: 500), (timer) {
//         if (_gameModel.isPlaying) {
//           setState(() {
//             _gameModel.moveDown();
//           });
//         }
//         if (_gameModel.isGameOver) {
//           _updateHighScore();
//           _profileService.addXp(_profile, _gameModel.score);
//           _preferencesService.incrementLinesCleared(_gameModel.linesCleared);
//           _preferencesService.updateTotalTimePlayed(
//             const Duration(milliseconds: 500),
//           );
//         }
//       });
//     }
//   }

//   void _loadProfile() async {
//     _profile = await _profileService.getProfile();
//     setState(() {});
//   }

//   void _loadHighScore() {
//     switch (widget.gameMode) {
//       case GameMode.classic:
//         _highScore = _preferencesService.highScoreClassic;
//         break;
//       case GameMode.sprint:
//         _highScore = _preferencesService.highScoreSprint;
//         break;
//       case GameMode.marathon:
//         _highScore = _preferencesService.highScoreMarathon;
//         break;
//       case GameMode.zen:
//         _highScore = _preferencesService.highScoreZen;
//         break;
//     }
//     setState(() {});
//   }

//   void _updateHighScore() {
//     if (_gameModel.score > _highScore) {
//       _highScore = _gameModel.score;
//       _preferencesService.setHighScore(
//         widget.gameMode.toString().split('.').last,
//         _highScore,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       body: KeyboardListener(
//         focusNode: FocusNode(),
//         autofocus: true,
//         onKeyEvent: (event) {
//           if (_gameModel.isPlaying) {
//             if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.arrowLeft,
//             )) {
//               setState(() => _gameModel.moveLeft());
//             } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.arrowRight,
//             )) {
//               setState(() => _gameModel.moveRight());
//             } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.arrowUp,
//             )) {
//               setState(() {
//                 _gameModel.rotate();
//                 _soundService.playRotateSound();
//               });
//             } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.arrowDown,
//             )) {
//               setState(() {
//                 _gameModel.moveDown();
//                 _soundService.playDropSound();
//               });
//             } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.space,
//             )) {
//               setState(() {
//                 _gameModel.hardDrop();
//                 _controller.forward(from: 0);
//               });
//             } else if (HardwareKeyboard.instance.isLogicalKeyPressed(
//               LogicalKeyboardKey.keyC,
//             )) {
//               setState(() => _gameModel.hold());
//             }
//           }
//           if (HardwareKeyboard.instance.isLogicalKeyPressed(
//             LogicalKeyboardKey.keyP,
//           )) {
//             setState(() => _gameModel.togglePause());
//           }
//         },
//         child: Stack(
//           children: [
//             const ParticleBackground(),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildInfoPanel(
//                             'SCORE', _gameModel.score.toString()),
//                         _buildInfoPanel(
//                             'LINES', _gameModel.linesCleared.toString()),
//                         _buildInfoPanel(
//                             'LEVEL', _gameModel.level.toString()),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 8,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'HELD',
//                                 style: GoogleFonts.pressStart2p(
//                                     color: theme.colorScheme.onBackground),
//                               ),
//                               PiecePreview(
//                                 piece: _gameModel.heldPiece,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 3,
//                           child: LayoutBuilder(
//                             builder: (context, constraints) {
//                               return SizedBox(
//                                 width: constraints.maxWidth,
//                                 height: constraints.maxHeight,
//                                 child: Stack(
//                                   children: [
//                                     ValueListenableBuilder<BlockSkin>(
//                                       valueListenable: blockSkinNotifier,
//                                       builder: (context, blockSkin, child) {
//                                         return AnimatedBuilder(
//                                           animation: _animation,
//                                           builder: (context, child) {
//                                             return Transform.translate(
//                                               offset:
//                                                   Offset(_animation.value, 0),
//                                               child: child,
//                                             );
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                 color:
//                                                     theme.colorScheme.primary,
//                                                 width: 2,
//                                               ),
//                                             ),
//                                             child: GameBoard(
//                                               gameModel: _gameModel,
//                                               blockSkin: blockSkin,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                     if (_gameModel.isGameOver)
//                                       _buildGameOverOverlay(),
//                                     if (!_gameModel.isPlaying &&
//                                         !_gameModel.isGameOver)
//                                       _buildPausedOverlay(),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'NEXT',
//                                 style: GoogleFonts.pressStart2p(
//                                     color: theme.colorScheme.onBackground),
//                               ),
//                               PiecePreview(
//                                 piece: _gameModel.nextPiece,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: _buildControlButtons(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoPanel(String title, String value) {
//     final theme = Theme.of(context);
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.pressStart2p(
//               color: theme.colorScheme.onBackground, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: GoogleFonts.pressStart2p(
//               color: theme.colorScheme.onBackground, fontSize: 20),
//         ),
//       ],
//     );
//   }

//   Widget _buildGameOverOverlay() {
//     final theme = Theme.of(context);
//     return Center(
//       child: Container(
//         color: Colors.black.withOpacity(0.75),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Game Over',
//               style: GoogleFonts.pressStart2p(
//                 fontSize: 48,
//                 color: theme.colorScheme.onBackground,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _gameModel.restart();
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary,
//                   ),
//                   child: Text(
//                     'RESTART',
//                     style: GoogleFonts.pressStart2p(
//                         color: theme.colorScheme.onPrimary),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.secondary,
//                   ),
//                   child: Text(
//                     'EXIT',
//                     style: GoogleFonts.pressStart2p(
//                         color: theme.colorScheme.onSecondary),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPausedOverlay() {
//     final theme = Theme.of(context);
//     return Center(
//       child: Text(
//         'Paused',
//         style: TextStyle(
//           fontSize: 48,
//           color: theme.colorScheme.onBackground,
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButtons() {
//     final theme = Theme.of(context);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(Icons.rotate_right,
//                   color: theme.colorScheme.onBackground, size: 48),
//               onPressed: () => setState(() => _gameModel.rotate()),
//             ),
//             IconButton(
//               icon: Icon(Icons.swap_horiz,
//                   color: theme.colorScheme.onBackground, size: 48),
//               onPressed: () => setState(() => _gameModel.hold()),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_left,
//                   color: theme.colorScheme.onBackground, size: 48),
//               onPressed: () => setState(() => _gameModel.moveLeft()),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_downward,
//                       color: theme.colorScheme.onBackground, size: 48),
//                   onPressed: () => setState(() => _gameModel.moveDown()),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.keyboard_double_arrow_down,
//                       color: theme.colorScheme.onBackground, size: 48),
//                   onPressed: () => setState(() => _gameModel.hardDrop()),
//                 ),
//               ],
//             ),
//             IconButton(
//               icon: Icon(Icons.arrow_right,
//                   color: theme.colorScheme.onBackground, size: 48),
//               onPressed: () => setState(() => _gameModel.moveRight()),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/block_skin.dart';
import '../models/game_mode.dart';
import '../models/game_model.dart';
import '../models/player_profile.dart';
import '../services/player_profile_service.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_preview.dart';
import '../widgets/particle_background.dart';
import '../main.dart';

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
          _preferencesService.updateTotalTimePlayed(
            const Duration(milliseconds: 500),
          );
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
        widget.gameMode.toString().split('.').last,
        _highScore,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: (event) {
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
        },
        child: Stack(
          children: [
            const ParticleBackground(),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn('SCORE', _gameModel.score.toString()),
                                    _buildStatColumn('LINES', _gameModel.linesCleared.toString()),
                                    _buildStatColumn('LEVEL', _gameModel.level.toString()),
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
                          child: Container(
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, gameConstraints) {
                                // Calculate proper game board size
                                final aspectRatio = 10.0 / 20.0;
                                double boardWidth, boardHeight;
                                
                                if (gameConstraints.maxWidth / gameConstraints.maxHeight > aspectRatio) {
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
                                            gridColor: theme.colorScheme.onBackground.withOpacity(0.1),
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
                                        if (_gameModel.isGameOver) _buildGameOverOverlay(),
                                        if (!_gameModel.isPlaying && !_gameModel.isGameOver)
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
                        
                        // Control buttons - fixed height, properly constrained
                        Container(
                          height: 80,
                          child: Row(
                            children: [
                              // Left side - action buttons
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionButton(
                                            Icons.rotate_right,
                                            'ROTATE',
                                            () => setState(() => _gameModel.rotate()),
                                          ),
                                          _buildActionButton(
                                            Icons.swap_horiz,
                                            'HOLD',
                                            () => setState(() => _gameModel.hold()),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: _buildActionButton(
                                        Icons.pause,
                                        'PAUSE',
                                        () => setState(() => _gameModel.togglePause()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Right side - movement controls
                              Container(
                                width: 120,
                                height: 80,
                                child: Column(
                                  children: [
                                    // Top row - soft drop
                                    Expanded(
                                      child: Center(
                                        child: _buildMovementButton(
                                          Icons.keyboard_arrow_down,
                                          () => setState(() => _gameModel.moveDown()),
                                        ),
                                      ),
                                    ),
                                    // Middle row - left, hard drop, right
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildMovementButton(
                                            Icons.keyboard_arrow_left,
                                            () => setState(() => _gameModel.moveLeft()),
                                          ),
                                          _buildMovementButton(
                                            Icons.keyboard_double_arrow_down,
                                            () => setState(() => _gameModel.hardDrop()),
                                          ),
                                          _buildMovementButton(
                                            Icons.keyboard_arrow_right,
                                            () => setState(() => _gameModel.moveRight()),
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

  Widget _buildStatColumn(String label, String value) {
    final theme = Theme.of(context);
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.pressStart2p(
              color: theme.colorScheme.onBackground,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
            color: theme.colorScheme.onBackground.withOpacity(0.7),
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: PiecePreview(piece: piece),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.onBackground, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  color: theme.colorScheme.onBackground,
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovementButton(IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onBackground,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GAME OVER',
              style: GoogleFonts.pressStart2p(
                fontSize: 20,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${_gameModel.score}',
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    'RESTART',
                    style: GoogleFonts.pressStart2p(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    'EXIT',
                    style: GoogleFonts.pressStart2p(
                      color: theme.colorScheme.onSecondary,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedOverlay() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          'PAUSED',
          style: GoogleFonts.pressStart2p(
            fontSize: 24,
            color: theme.colorScheme.onBackground,
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
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}