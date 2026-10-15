import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NeonCyberMazeApp());
}

const Color neonCyan = Color(0xFF00F5FF);
const Color neonPurple = Color(0xFFB026FF);
const Color neonPink = Color(0xFFFF2E93);
const Color backgroundColor = Color(0xFF050816);

class NeonCyberMazeApp extends StatelessWidget {
  const NeonCyberMazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Cyber Maze Monster',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonPurple,
        ),
      ),
      home: const CyberMazeScreen(),
    );
  }
}

class CyberMazeScreen extends StatefulWidget {
  const CyberMazeScreen({super.key});

  @override
  State<CyberMazeScreen> createState() => _CyberMazeScreenState();
}

class _CyberMazeScreenState extends State<CyberMazeScreen> {
  // # = wall, . = energy orb, P = player, M = monster
  static const List<String> _layout = [
    '###############',
    '#P....#.......#',
    '#.##..#..###..#',
    '#......#......#',
    '###.##...##.###',
    '#...#.....#...#',
    '#.#.#.###.#.#.#',
    '#.#...#...#.#.#',
    '#.###.#.###.#.#',
    '#.....#.....#.#',
    '#.###...###...#',
    '#...#.....#...#',
    '###.#.###.#.###',
    '#...........M.#',
    '###############',
  ];

  late List<List<String>> _maze;

  int _playerX = 1;
  int _playerY = 1;
  int _monsterX = 12;
  int _monsterY = 13;

  int _score = 0;
  int _ticks = 0;
  int _lives = 3;

  bool _playing = true;
  bool _won = false;
  bool _started = false;

  Timer? _timer;
  final FocusNode _focusNode = FocusNode();

  int get _secondsLeft => math.max(0, 120 - _ticks ~/ 6);

  @override
  void initState() {
    super.initState();
    _resetMaze();
  }

  void _resetMaze() {
    _maze = _layout.map((row) => row.split('')).toList();

    for (int y = 0; y < _maze.length; y++) {
      for (int x = 0; x < _maze[y].length; x++) {
        if (_maze[y][x] == 'P') {
          _playerX = x;
          _playerY = y;
          _maze[y][x] = ' ';
        } else if (_maze[y][x] == 'M') {
          _monsterX = x;
          _monsterY = y;
          _maze[y][x] = ' ';
        }
      }
    }
  }

  void _startGame() {
    if (_started) return;

    setState(() {
      _started = true;
      _playing = true;
    });

    _timer = Timer.periodic(
      const Duration(milliseconds: 160),
      (_) => _gameTick(),
    );

    _focusNode.requestFocus();
  }

  void _restartGame() {
    _timer?.cancel();

    setState(() {
      _resetMaze();
      _score = 0;
      _ticks = 0;
      _lives = 3;
      _playing = true;
      _won = false;
      _started = false;
    });

    _startGame();
  }

  bool _isOpen(int x, int y) {
    return y >= 0 &&
        y < _maze.length &&
        x >= 0 &&
        x < _maze[y].length &&
        _maze[y][x] != '#';
  }

  void _movePlayer(int dx, int dy) {
    if (!_playing) return;

    if (!_started) {
      _startGame();
    }

    final int nx = _playerX + dx;
    final int ny = _playerY + dy;

    if (!_isOpen(nx, ny)) return;

    setState(() {
      _playerX = nx;
      _playerY = ny;

      if (_maze[ny][nx] == '.') {
        _maze[ny][nx] = ' ';
        _score += 10;
      }

      _checkCollision();

      if (_playing && !_hasPellets()) {
        _finishGame(true);
      }
    });
  }

  bool _hasPellets() {
    for (final row in _maze) {
      if (row.contains('.')) return true;
    }
    return false;
  }

  void _gameTick() {
    if (!_playing || !_started) return;

    setState(() {
      _ticks++;

      if (_secondsLeft <= 0) {
        _finishGame(false);
        return;
      }

      // The monster moves every fourth tick.
      if (_ticks % 4 == 0) {
        _moveMonster();
        _checkCollision();
      }
    });
  }

  void _moveMonster() {
    // Breadth-first search calculates distances from the player.
    final rows = _maze.length;
    final cols = _maze[0].length;

    final distances = List.generate(
      rows,
      (_) => List<int>.filled(cols, -1),
    );

    final queue = <(int, int)>[];
    queue.add((_playerX, _playerY));
    distances[_playerY][_playerX] = 0;

    const directions = <(int, int)>[
      (0, -1),
      (0, 1),
      (-1, 0),
      (1, 0),
    ];

    int index = 0;

    while (index < queue.length) {
      final (x, y) = queue[index++];

      for (final (dx, dy) in directions) {
        final nx = x + dx;
        final ny = y + dy;

        if (_isOpen(nx, ny) && distances[ny][nx] == -1) {
          distances[ny][nx] = distances[y][x] + 1;
          queue.add((nx, ny));
        }
      }
    }

    // Choose the reachable adjacent tile closest to the player.
    int bestX = _monsterX;
    int bestY = _monsterY;
    int bestDistance = 999999;

    for (final (dx, dy) in directions) {
      final nx = _monsterX + dx;
      final ny = _monsterY + dy;

      if (!_isOpen(nx, ny)) continue;

      final distance = distances[ny][nx];

      if (distance >= 0 && distance < bestDistance) {
        bestDistance = distance;
        bestX = nx;
        bestY = ny;
      }
    }

    _monsterX = bestX;
    _monsterY = bestY;
  }

  void _checkCollision() {
    if (_playerX == _monsterX && _playerY == _monsterY) {
      _lives--;

      if (_lives <= 0) {
        _finishGame(false);
        return;
      }

      // Respawn the player after being caught.
      _playerX = 1;
      _playerY = 1;
    }
  }

  void _finishGame(bool won) {
    _playing = false;
    _won = won;
    _timer?.cancel();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.keyR && !_playing) {
      _restartGame();
      return;
    }

    if (!_playing) return;

    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW) {
      _movePlayer(0, -1);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS) {
      _movePlayer(0, 1);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA) {
      _movePlayer(-1, 0);
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _movePlayer(1, 0);
    } else if (key == LogicalKeyboardKey.space) {
      if (!_started) _startGame();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'NEON CYBER MAZE',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: neonCyan,
                  shadows: [
                    Shadow(color: neonCyan, blurRadius: 15),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'MONSTER ESCAPE PROTOCOL',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: neonPurple,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _hud('SCORE', '$_score', neonCyan),
                    _hud('TIME', '$_secondsLeft', neonPink),
                    _hud('LIVES', '$_lives', neonPurple),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final side = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return SizedBox(
                        width: side,
                        height: side,
                        child: CustomPaint(
                          painter: MazePainter(
                            maze: _maze,
                            playerX: _playerX,
                            playerY: _playerY,
                            monsterX: _monsterX,
                            monsterY: _monsterY,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!_started && _playing)
                const Text(
                  'COLLECT ALL ENERGY ORBS!',
                  style: TextStyle(
                    color: neonCyan,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              if (!_playing) ...[
                Text(
                  _won ? 'LEVEL CLEARED!' : 'SYSTEM FAILURE',
                  style: TextStyle(
                    color: _won ? neonCyan : neonPink,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: _won ? neonCyan : neonPink,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Final score: $_score',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('PLAY AGAIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              _buildControls(),
              const SizedBox(height: 8),
              const Text(
                'ARROWS / WASD   •   R TO RESTART AFTER GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white38,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hud(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: color, blurRadius: 10)],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _directionButton(Icons.keyboard_arrow_up, 0, -1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _directionButton(Icons.keyboard_arrow_left, -1, 0),
              const SizedBox(width: 52),
              _directionButton(Icons.keyboard_arrow_right, 1, 0),
            ],
          ),
          _directionButton(Icons.keyboard_arrow_down, 0, 1),
        ],
      ),
    );
  }

  Widget _directionButton(IconData icon, int dx, int dy) {
    return SizedBox(
      width: 46,
      height: 38,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: OutlinedButton(
          onPressed: _playing ? () => _movePlayer(dx, dy) : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: neonCyan,
            side: const BorderSide(color: neonCyan, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(icon, size: 26),
        ),
      ),
    );
  }
}

class MazePainter extends CustomPainter {
  final List<List<String>> maze;
  final int playerX;
  final int playerY;
  final int monsterX;
  final int monsterY;

  MazePainter({
    required this.maze,
    required this.playerX,
    required this.playerY,
    required this.monsterX,
    required this.monsterY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = maze.length;
    final cols = maze[0].length;
    final tileW = size.width / cols;
    final tileH = size.height / rows;

    final background = Paint()..color = const Color(0xFF070B1B);
    canvas.drawRect(Offset.zero & size, background);

    // Draw walls and collectible orbs.
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final rect = Rect.fromLTWH(
          x * tileW,
          y * tileH,
          tileW,
          tileH,
        );

        if (maze[y][x] == '#') {
          final wallRect = rect.deflate(math.min(tileW, tileH) * 0.09);

          final glowPaint = Paint()
            ..color = neonCyan.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              wallRect,
              Radius.circular(tileW * 0.18),
            ),
            glowPaint,
          );

          final wallPaint = Paint()
            ..color = const Color(0xFF102E49)
            ..style = PaintingStyle.fill;

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              wallRect,
              Radius.circular(tileW * 0.18),
            ),
            wallPaint,
          );

          final borderPaint = Paint()
            ..color = neonCyan.withValues(alpha: 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              wallRect,
              Radius.circular(tileW * 0.18),
            ),
            borderPaint,
          );
        } else if (maze[y][x] == '.') {
          final center = Offset(
            (x + 0.5) * tileW,
            (y + 0.5) * tileH,
          );

          final glow = Paint()
            ..color = neonPink.withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

          canvas.drawCircle(center, tileW * 0.23, glow);

          canvas.drawCircle(
            center,
            tileW * 0.105,
            Paint()..color = Colors.white,
          );

          canvas.drawCircle(
            center,
            tileW * 0.07,
            Paint()..color = neonPink,
          );
        }
      }
    }

    _drawPlayer(canvas, tileW, tileH);
    _drawMonster(canvas, tileW, tileH);
  }

  void _drawPlayer(Canvas canvas, double tileW, double tileH) {
    final center = Offset(
      (playerX + 0.5) * tileW,
      (playerY + 0.5) * tileH,
    );

    final radius = math.min(tileW, tileH) * 0.32;

    final glow = Paint()
      ..color = neonCyan.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawCircle(center, radius * 1.3, glow);
    canvas.drawCircle(center, radius, Paint()..color = neonCyan);
    canvas.drawCircle(
      center,
      radius * 0.53,
      Paint()..color = const Color(0xFF063347),
    );

    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()..color = Colors.white,
    );
  }

  void _drawMonster(Canvas canvas, double tileW, double tileH) {
    final center = Offset(
      (monsterX + 0.5) * tileW,
      (monsterY + 0.5) * tileH,
    );

    final radius = math.min(tileW, tileH) * 0.34;

    final glow = Paint()
      ..color = neonPurple.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius * 1.3, glow);

    final body = Path()
      ..moveTo(center.dx - radius, center.dy + radius * 0.8)
      ..lineTo(center.dx - radius, center.dy - radius * 0.15)
      ..quadraticBezierTo(
        center.dx - radius,
        center.dy - radius * 1.1,
        center.dx,
        center.dy - radius,
      )
      ..quadraticBezierTo(
        center.dx + radius,
        center.dy - radius * 1.1,
        center.dx + radius,
        center.dy - radius * 0.15,
      )
      ..lineTo(center.dx + radius, center.dy + radius * 0.8)
      ..lineTo(center.dx + radius * 0.35, center.dy + radius * 0.45)
      ..lineTo(center.dx, center.dy + radius * 0.8)
      ..lineTo(center.dx - radius * 0.35, center.dy + radius * 0.45)
      ..close();

    canvas.drawPath(body, Paint()..color = neonPurple);

    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = neonPink;

    canvas.drawCircle(
      Offset(center.dx - radius * 0.35, center.dy - radius * 0.05),
      radius * 0.22,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.05),
      radius * 0.22,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.02),
      radius * 0.11,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.02),
      radius * 0.11,
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MazePainter oldDelegate) => true;
}
