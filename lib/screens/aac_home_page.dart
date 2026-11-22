import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/aac_content.dart';
import '../models/aac_models.dart';
import '../widgets/aac_grid_button.dart';

class AACHomePage extends StatefulWidget {
  const AACHomePage({super.key});

  @override
  State<AACHomePage> createState() => _AACHomePageState();
}

class _AACHomePageState extends State<AACHomePage>
    with TickerProviderStateMixin {
  late final AACNavigator navigator;
  final List<AACButton> selectedButtons = [];
  final FlutterTts flutterTts = FlutterTts();

  final GlobalKey _messageBarKey = GlobalKey();
  OverlayEntry? _flyingOverlay;

  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    navigator = AACNavigator(aacData);
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
    _ttsReady = true;
  }

  void onButtonTapped(AACButton button, GlobalKey? buttonKey) {
    switch (button.action) {
      case ButtonAction.speak:
        _startFlyAnimation(button, buttonKey);
        setState(() {
          selectedButtons.add(button);
        });
        break;
      case ButtonAction.navigate:
        if (button.loadBoardId != null) {
          setState(() {
            navigator.goTo(button.loadBoardId!);
          });
        }
        break;
      case ButtonAction.special:
        setState(() {
          navigator.handleSpecial(button.specialAction);
        });
        break;
    }
  }

  void _startFlyAnimation(AACButton button, GlobalKey? buttonKey) {
    if (buttonKey == null || buttonKey.currentContext == null) return;

    final RenderBox buttonBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;

    final RenderBox? messageBox =
        _messageBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (messageBox == null) return;

    final Offset messagePosition = messageBox.localToGlobal(Offset.zero);
    final Size messageSize = messageBox.size;

    // Calculate where the new item will appear in the horizontal list
    const double itemWidth = 68.0;
    final int currentCount = selectedButtons.length;
    final double targetX = messagePosition.dx + 12 + (currentCount * itemWidth);
    final double targetY = messagePosition.dy + (messageSize.height / 2) - 22;

    // Clamp so it doesn't fly past the clear/speak buttons
    final double maxX = messagePosition.dx + messageSize.width - 140;
    final Offset target = Offset(
      targetX.clamp(messagePosition.dx + 12, maxX),
      targetY,
    );

    final imagePath = aacData.images?[button.imageId]?.path;

    _flyingOverlay?.remove();
    _flyingOverlay = OverlayEntry(
      builder: (context) {
        return _FlyingButton(
          start: buttonPosition,
          size: buttonSize,
          target: target,
          label: button.label,
          imagePath: imagePath,
          onComplete: () {
            _flyingOverlay?.remove();
            _flyingOverlay = null;
          },
        );
      },
    );

    Overlay.of(context).insert(_flyingOverlay!);
  }

  void clearMessage() {
    setState(() {
      selectedButtons.clear();
    });
    flutterTts.stop();
  }

  Future<void> speakMessage() async {
    if (selectedButtons.isEmpty || !_ttsReady) return;

    final message = selectedButtons
        .map((b) => b.vocalization ?? b.label)
        .join(" ");

    try {
      await flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 80));
      await flutterTts.speak(message);
    } catch (e) {
      debugPrint("TTS speak failed: $e");
    }
  }

  @override
  void dispose() {
    _flyingOverlay?.remove();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = navigator.currentBoard;
    final rows = aacData.gridRows;
    final cols = aacData.gridColumns;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE6DC),
      appBar: AppBar(
        title: Text(
          board.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A342C),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF3EDE4),
        toolbarHeight: 46,
      ),
      body: Column(
        children: [
          // ─── MESSAGE BAR ───────────────────────────────────────────
          Container(
            key: _messageBarKey,
            height: 90,
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD9D0C3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedButtons.isEmpty
                      ? Center(
                          child: Text(
                            'Your message goes here',
                            style: TextStyle(
                              color: Colors.brown.shade400,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedButtons.length,
                          itemBuilder: (context, index) {
                            final button = selectedButtons[index];
                            final imagePath =
                                aacData.images?[button.imageId]?.path;

                            return Container(
                              width: 62,
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EDE4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFD9D0C3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: imagePath != null
                                        ? Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  size: 20,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.image_not_supported,
                                            size: 20,
                                          ),
                                  ),
                                  Text(
                                    button.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3A342C),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(width: 8),

                // Clear
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Clear',
                  color: const Color(0xFF5C5346),
                  background: const Color(0xFFE8E0D5),
                  onTap: clearMessage,
                ),

                const SizedBox(width: 8),

                // Speak
                _ActionButton(
                  icon: Icons.volume_up_rounded,
                  label: 'Speak',
                  color: Colors.white,
                  background: const Color(0xFF8B6F4E),
                  onTap: selectedButtons.isEmpty ? null : speakMessage,
                ),
              ],
            ),
          ),

          // ─── GRID ──────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 7.0;
                const padding = 9.0;

                final buttonWidth =
                    (constraints.maxWidth -
                        padding * 2 -
                        spacing * (cols - 1)) /
                    cols;
                final buttonHeight =
                    (constraints.maxHeight -
                        padding * 2 -
                        spacing * (rows - 1)) /
                    rows;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(padding),
                  itemCount: rows * cols,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: buttonWidth / buttonHeight,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ cols;
                    final col = index % cols;
                    final button = board.buttonAt(row, col);

                    if (button == null) {
                      return const SizedBox.shrink();
                    }

                    final imagePath = aacData.images?[button.imageId]?.path;
                    final buttonKey = GlobalKey();

                    return AACGridButton(
                      key: ValueKey(button.id),
                      buttonKey: buttonKey,
                      label: button.label,
                      imagePath: imagePath,
                      onTap: () => onButtonTapped(button, buttonKey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 66,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyingButton extends StatefulWidget {
  final Offset start;
  final Size size;
  final Offset target;
  final String label;
  final String? imagePath;
  final VoidCallback onComplete;

  const _FlyingButton({
    required this.start,
    required this.size,
    required this.target,
    required this.label,
    this.imagePath,
    required this.onComplete,
  });

  @override
  State<_FlyingButton> createState() => _FlyingButtonState();
}

class _FlyingButtonState extends State<_FlyingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _position = Tween<Offset>(begin: widget.start, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.42,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDE4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9D0C3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Expanded(
                        child: widget.imagePath != null
                            ? Image.asset(
                                widget.imagePath!,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A342C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
