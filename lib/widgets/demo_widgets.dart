import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DemoNotice extends StatelessWidget {
  const DemoNotice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0D7),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Color(0xFF98601E), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF795322),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Card(
    color: selected ? const Color(0xFFE5F0E3) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: selected ? green : const Color(0xFFE3E7DB),
        width: selected ? 2 : 1,
      ),
    ),
    child: ListTile(
      minVerticalPadding: 10,
      leading: icon == null ? null : Icon(icon, color: green),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? green : muted,
      ),
      onTap: onTap,
    ),
  );
}

/// A small local vector tractor drawing; it needs no network or image package.
class TractorIllustration extends StatelessWidget {
  const TractorIllustration({super.key, this.width = 142, this.height = 104});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Illustration of a green farm tractor',
    child: ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: const _TractorPainter(),
      ),
    ),
  );
}

class _TractorPainter extends CustomPainter {
  const _TractorPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 142;
    final sy = size.height / 104;
    canvas.save();
    canvas.scale(sx, sy);
    final shadow = Paint()..color = const Color(0x330E3425);
    canvas.drawOval(const Rect.fromLTWH(12, 83, 118, 12), shadow);

    final tire = Paint()..color = const Color(0xFF26352E);
    final rim = Paint()..color = const Color(0xFFD6B05D);
    canvas.drawCircle(const Offset(39, 75), 24, tire);
    canvas.drawCircle(const Offset(39, 75), 11, rim);
    canvas.drawCircle(const Offset(112, 78), 16, tire);
    canvas.drawCircle(const Offset(112, 78), 7, rim);

    final body = Paint()..color = const Color(0xFF24834C);
    final bodyDark = Paint()..color = const Color(0xFF17623E);
    final glass = Paint()..color = const Color(0xFFAED5D4);
    final cream = Paint()..color = const Color(0xFFFFF2D1);
    final stroke = Paint()
      ..color = const Color(0xFF10462F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    final chassis = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 48, 90, 22),
      const Radius.circular(7),
    );
    canvas.drawRRect(chassis, body);
    canvas.drawRRect(chassis, stroke);
    final hood = RRect.fromRectAndRadius(
      const Rect.fromLTWH(86, 43, 43, 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(hood, body);
    canvas.drawRRect(hood, stroke);

    final cab = Path()
      ..moveTo(48, 49)
      ..lineTo(52, 22)
      ..lineTo(82, 22)
      ..lineTo(89, 49)
      ..close();
    canvas.drawPath(cab, bodyDark);
    canvas.drawPath(cab, stroke);
    final windshield = Path()
      ..moveTo(56, 27)
      ..lineTo(77, 27)
      ..lineTo(82, 45)
      ..lineTo(53, 45)
      ..close();
    canvas.drawPath(windshield, glass);
    canvas.drawLine(const Offset(66, 27), const Offset(66, 45), stroke);
    canvas.drawRect(const Rect.fromLTWH(91, 32, 4, 12), bodyDark);
    canvas.drawLine(const Offset(91, 32), const Offset(91, 24), stroke);
    canvas.drawCircle(const Offset(128, 52), 4, cream);
    canvas.drawLine(const Offset(25, 47), const Offset(42, 43), stroke);

    final hub = Paint()..color = const Color(0xFFFFF3D6);
    canvas.drawCircle(const Offset(39, 75), 4, hub);
    canvas.drawCircle(const Offset(112, 78), 3, hub);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TractorPainter oldDelegate) => false;
}
