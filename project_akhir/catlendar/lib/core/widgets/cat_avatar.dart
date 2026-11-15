import 'package:flutter/material.dart';

class CatAvatar extends StatelessWidget {
  const CatAvatar({
    super.key,
    required this.avatarId,
    this.catColor,
    this.radius = 36,
    this.isSelected = false,
    this.showBorder = false,
    this.fallbackName,
  });

  final String? avatarId;
  final String? catColor;
  final double radius;
  final bool isSelected;
  final bool showBorder;
  final String? fallbackName;

  /// Warna lingkaran latar & variasi aksesoris tiap preset agar kucing
  /// dengan warna bulu yang sama tetap mudah dibedakan.
  static ({Color bg, Color accent}) _presetStyle(String? id) {
    return switch (id) {
      'cat_1' => (bg: const Color(0xFFFFE0B2), accent: const Color(0xFFE65100)),
      'cat_2' => (bg: const Color(0xFFB3E5FC), accent: const Color(0xFF0277BD)),
      'cat_3' => (bg: const Color(0xFFC8E6C9), accent: const Color(0xFF2E7D32)),
      'cat_4' => (bg: const Color(0xFFF8BBD0), accent: const Color(0xFFC2185B)),
      'cat_5' => (bg: const Color(0xFFE1BEE7), accent: const Color(0xFF6A1B9A)),
      'cat_6' => (bg: const Color(0xFFFFF9C4), accent: const Color(0xFFF57F17)),
      _ => (bg: Colors.grey.shade200, accent: Colors.grey.shade700),
    };
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presetStyle(avatarId);
    final diameter = radius * 2;
    final hasRing = isSelected || showBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: preset.bg,
        border: hasRing
            ? Border.all(
                color: isSelected ? Colors.black : Colors.white,
                width: isSelected ? 2.5 : 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: (avatarId == null &&
              fallbackName != null &&
              fallbackName!.trim().isNotEmpty)
          ? Center(
              child: Text(
                fallbackName!.trim()[0].toUpperCase(),
                style: TextStyle(
                  fontSize: radius * 0.75,
                  fontWeight: FontWeight.bold,
                  color: preset.accent,
                ),
              ),
            )
          : CustomPaint(
              size: Size(diameter, diameter),
              painter: _CatFacePainter(
                avatarId: avatarId ?? 'cat_1',
                catColor: catColor,
              ),
            ),
    );
  }
}

class _CatFacePainter extends CustomPainter {
  const _CatFacePainter({
    required this.avatarId,
    required this.catColor,
  });

  final String avatarId;
  final String? catColor;

  Color _baseFurColor(String? color) {
    return switch (color?.toLowerCase()) {
      'black' => const Color(0xFF2B2B30),
      'white' => const Color(0xFFFAFAFA),
      'orange' => const Color(0xFFF57C00),
      'grey' => const Color(0xFF78909C),
      'calico' => const Color(0xFFFFFDF9),
      'tabby' => const Color(0xFF9E7B56),
      'bicolor' => const Color(0xFF2B2B30),
      'tortoiseshell' => const Color(0xFF3E2723),
      'cream' => const Color(0xFFFFE0B2),
      'brown' => const Color(0xFF6D4C41),
      _ => const Color(0xFF607D8B),
    };
  }

  bool get _isDarkFur {
    final c = catColor?.toLowerCase();
    return c == 'black' ||
        c == 'bicolor' ||
        c == 'tortoiseshell' ||
        c == 'brown';
  }

  Path _buildHeadPath(double w, double h) {
    return Path()
      ..moveTo(0.22 * w, 0.54 * h)
      ..lineTo(0.22 * w, 0.42 * h)
      ..lineTo(0.24 * w, 0.20 * h)
      ..lineTo(0.41 * w, 0.34 * h)
      ..quadraticBezierTo(0.50 * w, 0.32 * h, 0.59 * w, 0.34 * h)
      ..lineTo(0.76 * w, 0.20 * h)
      ..lineTo(0.78 * w, 0.42 * h)
      ..lineTo(0.78 * w, 0.54 * h)
      ..cubicTo(0.78 * w, 0.74 * h, 0.64 * w, 0.79 * h, 0.50 * w, 0.79 * h)
      ..cubicTo(0.36 * w, 0.79 * h, 0.22 * w, 0.74 * h, 0.22 * w, 0.54 * h)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headPath = _buildHeadPath(w, h);
    final furColor = _baseFurColor(catColor);
    final normalizedColor = catColor?.toLowerCase();

    // 1. Warna dasar kepala & telinga kucing
    canvas.drawPath(
      headPath,
      Paint()
        ..color = furColor
        ..style = PaintingStyle.fill,
    );

    // 2. Motif belang khusus (Calico, Bicolor, Tabby, Tortoiseshell)
    canvas.save();
    canvas.clipPath(headPath);

    if (normalizedColor == 'calico') {
      // Belang oranye di sisi kiri atas
      canvas.drawCircle(
        Offset(0.28 * w, 0.33 * h),
        0.22 * w,
        Paint()..color = const Color(0xFFF57C00),
      );
      // Belang hitam di sisi kanan
      canvas.drawCircle(
        Offset(0.74 * w, 0.38 * h),
        0.20 * w,
        Paint()..color = const Color(0xFF2B2B30),
      );
    } else if (normalizedColor == 'bicolor') {
      // Corak putih di area moncong bawah (tuxedo)
      final whiteMuzzle = Path()
        ..moveTo(0.50 * w, 0.50 * h)
        ..lineTo(0.24 * w, 0.78 * h)
        ..lineTo(0.76 * w, 0.78 * h)
        ..close();
      canvas.drawPath(whiteMuzzle, Paint()..color = const Color(0xFFFAFAFA));
    } else if (normalizedColor == 'tabby') {
      // Garis belang dahi khas kucing tabby
      final stripePaint = Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(0.43 * w, 0.36 * h),
        Offset(0.44 * w, 0.44 * h),
        stripePaint,
      );
      canvas.drawLine(
        Offset(0.50 * w, 0.34 * h),
        Offset(0.50 * w, 0.45 * h),
        stripePaint,
      );
      canvas.drawLine(
        Offset(0.57 * w, 0.36 * h),
        Offset(0.56 * w, 0.44 * h),
        stripePaint,
      );
    } else if (normalizedColor == 'tortoiseshell') {
      // Bercak oranye kecokelatan acak
      canvas.drawCircle(
        Offset(0.32 * w, 0.36 * h),
        0.15 * w,
        Paint()..color = const Color(0xFFE65100).withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        Offset(0.68 * w, 0.64 * h),
        0.14 * w,
        Paint()..color = const Color(0xFFFF8F00).withValues(alpha: 0.8),
      );
    }
    canvas.restore();

    // 3. Garis tepi tipis agar warna putih/cerah tetap tegas
    canvas.drawPath(
      headPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeJoin = StrokeJoin.round,
    );

    // 4. Bagian dalam telinga
    final innerEarPaint = Paint()..color = const Color(0xFFF48FB1);
    final leftInnerEar = Path()
      ..moveTo(0.26 * w, 0.39 * h)
      ..lineTo(0.27 * w, 0.25 * h)
      ..lineTo(0.37 * w, 0.35 * h)
      ..close();
    final rightInnerEar = Path()
      ..moveTo(0.74 * w, 0.39 * h)
      ..lineTo(0.73 * w, 0.25 * h)
      ..lineTo(0.63 * w, 0.35 * h)
      ..close();
    canvas.drawPath(leftInnerEar, innerEarPaint);
    canvas.drawPath(rightInnerEar, innerEarPaint);

    // 5. Mata (menyesuaikan kontras warna bulu)
    final eyeColor =
        _isDarkFur ? const Color(0xFFFFD54F) : const Color(0xFF263238);
    final eyePaint = Paint()..color = eyeColor;
    final eyeRadius = w * 0.044;
    canvas.drawCircle(Offset(0.38 * w, 0.54 * h), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(0.62 * w, 0.54 * h), eyeRadius, eyePaint);

    // Kilau mata kecil
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(0.368 * w, 0.528 * h),
      eyeRadius * 0.35,
      sparklePaint,
    );
    canvas.drawCircle(
      Offset(0.608 * w, 0.528 * h),
      eyeRadius * 0.35,
      sparklePaint,
    );

    // 6. Hidung & mulut mungil
    final nosePaint = Paint()..color = const Color(0xFFF06292);
    final nosePath = Path()
      ..moveTo(0.47 * w, 0.61 * h)
      ..lineTo(0.53 * w, 0.61 * h)
      ..lineTo(0.50 * w, 0.645 * h)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    final mouthColor = (normalizedColor == 'bicolor' || !_isDarkFur)
        ? const Color(0xFF37474F)
        : Colors.white70;
    final mouthPaint = Paint()
      ..color = mouthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(0.45 * w, 0.665 * h)
      ..quadraticBezierTo(0.475 * w, 0.69 * h, 0.50 * w, 0.66 * h)
      ..quadraticBezierTo(0.525 * w, 0.69 * h, 0.55 * w, 0.665 * h);
    canvas.drawPath(mouthPath, mouthPaint);

    // 7. Aksesori pembeda tiap preset (cat_1 .. cat_6)
    if (avatarId == 'cat_2') {
      // Lonceng emas kecil di bawah dagu
      canvas.drawCircle(
        Offset(0.50 * w, 0.81 * h),
        w * 0.055,
        Paint()..color = const Color(0xFFFFB300),
      );
    } else if (avatarId == 'cat_3') {
      // Daun kecil di atas kepala
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0.53 * w, 0.27 * h),
          width: w * 0.11,
          height: h * 0.06,
        ),
        Paint()..color = const Color(0xFF43A047),
      );
    } else if (avatarId == 'cat_4') {
      // Pipi merona
      final blushPaint = Paint()
        ..color = const Color(0xFFF48FB1).withValues(alpha: 0.65);
      canvas.drawCircle(Offset(0.31 * w, 0.61 * h), w * 0.04, blushPaint);
      canvas.drawCircle(Offset(0.69 * w, 0.61 * h), w * 0.04, blushPaint);
    } else if (avatarId == 'cat_5') {
      // Tanda bintang/titik emas di dahi
      canvas.drawCircle(
        Offset(0.50 * w, 0.43 * h),
        w * 0.032,
        Paint()..color = const Color(0xFFFDD835),
      );
    } else if (avatarId == 'cat_6') {
      // Dasi kupu-kupu kecil di bawah dagu
      final bowPaint = Paint()..color = const Color(0xFF1E88E5);
      final bow = Path()
        ..moveTo(0.50 * w, 0.81 * h)
        ..lineTo(0.41 * w, 0.77 * h)
        ..lineTo(0.41 * w, 0.85 * h)
        ..close()
        ..moveTo(0.50 * w, 0.81 * h)
        ..lineTo(0.59 * w, 0.77 * h)
        ..lineTo(0.59 * w, 0.85 * h)
        ..close();
      canvas.drawPath(bow, bowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CatFacePainter oldDelegate) {
    return oldDelegate.avatarId != avatarId || oldDelegate.catColor != catColor;
  }
}
