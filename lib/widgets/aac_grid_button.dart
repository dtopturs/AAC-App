import 'package:flutter/material.dart';

class AACGridButton extends StatefulWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onTap;
  final GlobalKey? buttonKey;

  const AACGridButton({
    super.key,
    required this.label,
    this.imagePath,
    required this.onTap,
    this.buttonKey,
  });

  @override
  State<AACGridButton> createState() => _AACGridButtonState();
}

class _AACGridButtonState extends State<AACGridButton> {
  double scale = 1.0;

  Future<void> _handleTap() async {
    setState(() => scale = 0.93);
    await Future.delayed(const Duration(milliseconds: 70));
    if (!mounted) return;
    setState(() => scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          key: widget.buttonKey,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EDE4), // warm cream
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD9D0C3), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 5,
                offset: const Offset(0, 2),
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
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 22),
                      )
                    : const Icon(Icons.image_not_supported, size: 22),
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A342C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
