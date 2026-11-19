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

  bool get _isNetworkImage => avatarId != null && avatarId!.startsWith('http');

  static ({Color bg, Color accent}) _presetStyle(String? id) {
    return switch (id) {
      'cat_1' => (bg: const Color(0xFFFFE0B2), accent: const Color(0xFFE65100)),
      'cat_2' => (bg: const Color(0xFFB3E5FC), accent: const Color(0xFF0277BD)),
      'cat_3' => (bg: const Color(0xFFC8E6C9), accent: const Color(0xFF2E7D32)),
      'cat_4' => (bg: const Color(0xFFF8BBD0), accent: const Color(0xFFC2185B)),
      'cat_5' => (bg: const Color(0xFFE1BEE7), accent: const Color(0xFF6A1B9A)),
      'cat_6' => (bg: const Color(0xFFFFF9C4), accent: const Color(0xFFF57F17)),
      'cat_7' => (bg: const Color(0xFFE3F2FD), accent: const Color(0xFFFFB300)),
      'cat_8' => (bg: const Color(0xFFFFCDD2), accent: const Color(0xFFC62828)),
      'cat_9' => (bg: const Color(0xFFD1C4E9), accent: const Color(0xFF4527A0)),
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
      child: _buildChild(preset, diameter),
    );
  }

  Widget _buildChild(({Color bg, Color accent}) preset, double diameter) {
    if (_isNetworkImage) {
      return Image.network(
        avatarId!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: radius * 0.7,
              height: radius * 0.7,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => CustomPaint(
          size: Size(diameter, diameter),
          painter: _CatFacePainter(
            avatarId: 'cat_1',
            catColor: catColor,
          ),
        ),
      );
    }

    if (avatarId == null &&
        fallbackName != null &&
        fallbackName!.trim().isNotEmpty) {
      return Center(
        child: Text(
          fallbackName!.trim()[0].toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
            color: preset.accent,
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _CatFacePainter(
        avatarId: avatarId ?? 'cat_1',
        catColor: catColor,
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

    // Elemen belakang kepala (sayap malaikat & ekor iblis)
    if (avatarId == 'cat_7') {
      _drawAngelWings(canvas, w, h);
    } else if (avatarId == 'cat_8') {
      _drawDevilTail(canvas, w, h);
    }

    // Dasar warna kepala kucing
    canvas.drawPath(
      headPath,
      Paint()
        ..color = furColor
        ..style = PaintingStyle.fill,
    );

    // Pola bulu khusus (Calico, Bicolor, Tabby, Tortoiseshell)
    canvas.save();
    canvas.clipPath(headPath);

    if (normalizedColor == 'calico') {
      canvas.drawCircle(
        Offset(0.28 * w, 0.33 * h),
        0.22 * w,
        Paint()..color = const Color(0xFFF57C00),
      );
      canvas.drawCircle(
        Offset(0.74 * w, 0.38 * h),
        0.20 * w,
        Paint()..color = const Color(0xFF2B2B30),
      );
    } else if (normalizedColor == 'bicolor') {
      final whiteMuzzle = Path()
        ..moveTo(0.50 * w, 0.50 * h)
        ..lineTo(0.24 * w, 0.78 * h)
        ..lineTo(0.76 * w, 0.78 * h)
        ..close();
      canvas.drawPath(whiteMuzzle, Paint()..color = const Color(0xFFFAFAFA));
    } else if (normalizedColor == 'tabby') {
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

    // Garis luar kepala
    canvas.drawPath(
      headPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeJoin = StrokeJoin.round,
    );

    // Bagian dalam telinga
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

    // Mata & kilau mata
    final eyeColor =
        _isDarkFur ? const Color(0xFFFFD54F) : const Color(0xFF263238);
    final eyePaint = Paint()..color = eyeColor;
    final eyeRadius = w * 0.044;
    canvas.drawCircle(Offset(0.38 * w, 0.54 * h), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(0.62 * w, 0.54 * h), eyeRadius, eyePaint);

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

    // Hidung
    final nosePaint = Paint()..color = const Color(0xFFF06292);
    final nosePath = Path()
      ..moveTo(0.47 * w, 0.61 * h)
      ..lineTo(0.53 * w, 0.61 * h)
      ..lineTo(0.50 * w, 0.645 * h)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mulut
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

    // Aksesori sesuai preset
    if (avatarId == 'cat_2') {
      canvas.drawCircle(
        Offset(0.50 * w, 0.81 * h),
        w * 0.055,
        Paint()..color = const Color(0xFFFFB300),
      );
    } else if (avatarId == 'cat_3') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0.53 * w, 0.27 * h),
          width: w * 0.11,
          height: h * 0.06,
        ),
        Paint()..color = const Color(0xFF43A047),
      );
    } else if (avatarId == 'cat_4') {
      final blushPaint = Paint()
        ..color = const Color(0xFFF48FB1).withValues(alpha: 0.65);
      canvas.drawCircle(Offset(0.31 * w, 0.61 * h), w * 0.04, blushPaint);
      canvas.drawCircle(Offset(0.69 * w, 0.61 * h), w * 0.04, blushPaint);
    } else if (avatarId == 'cat_5') {
      canvas.drawCircle(
        Offset(0.50 * w, 0.43 * h),
        w * 0.032,
        Paint()..color = const Color(0xFFFDD835),
      );
    } else if (avatarId == 'cat_6') {
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
    } else if (avatarId == 'cat_7') {
      _drawAngelHalo(canvas, w, h);
    } else if (avatarId == 'cat_8') {
      _drawDevilHornsAndFangs(canvas, w, h);
    } else if (avatarId == 'cat_9') {
      _drawWitchHat(canvas, w, h);
    }
  }

  void _drawAngelWings(Canvas canvas, double w, double h) {
    final wingFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final wingStroke = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeJoin = StrokeJoin.round;

    final leftWing = Path()
      ..moveTo(0.24 * w, 0.56 * h)
      ..quadraticBezierTo(0.08 * w, 0.43 * h, 0.11 * w, 0.56 * h)
      ..quadraticBezierTo(0.09 * w, 0.63 * h, 0.16 * w, 0.64 * h)
      ..quadraticBezierTo(0.14 * w, 0.70 * h, 0.25 * w, 0.67 * h)
      ..close();

    final rightWing = Path()
      ..moveTo(0.76 * w, 0.56 * h)
      ..quadraticBezierTo(0.92 * w, 0.43 * h, 0.89 * w, 0.56 * h)
      ..quadraticBezierTo(0.91 * w, 0.63 * h, 0.84 * w, 0.64 * h)
      ..quadraticBezierTo(0.86 * w, 0.70 * h, 0.75 * w, 0.67 * h)
      ..close();

    canvas.drawPath(leftWing, wingFill);
    canvas.drawPath(leftWing, wingStroke);
    canvas.drawPath(rightWing, wingFill);
    canvas.drawPath(rightWing, wingStroke);
  }

  void _drawAngelHalo(Canvas canvas, double w, double h) {
    final haloRect = Rect.fromCenter(
      center: Offset(0.50 * w, 0.13 * h),
      width: w * 0.34,
      height: h * 0.085,
    );

    canvas.drawOval(
      haloRect,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045,
    );
    canvas.drawOval(
      haloRect,
      Paint()
        ..color = const Color(0xFFFFB300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );
  }

  void _drawDevilTail(Canvas canvas, double w, double h) {
    final tailColor = const Color(0xFFD32F2F);
    final tailStem = Path()
      ..moveTo(0.75 * w, 0.68 * h)
      ..quadraticBezierTo(0.88 * w, 0.66 * h, 0.86 * w, 0.52 * h);

    canvas.drawPath(
      tailStem,
      Paint()
        ..color = tailColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024
        ..strokeCap = StrokeCap.round,
    );

    final tailTip = Path()
      ..moveTo(0.86 * w, 0.46 * h)
      ..lineTo(0.81 * w, 0.54 * h)
      ..lineTo(0.91 * w, 0.54 * h)
      ..close();
    canvas.drawPath(tailTip, Paint()..color = tailColor);
  }

  void _drawDevilHornsAndFangs(Canvas canvas, double w, double h) {
    final hornFill = Paint()..color = const Color(0xFFD32F2F);
    final hornStroke = Paint()
      ..color = const Color(0xFF7F0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.016
      ..strokeJoin = StrokeJoin.round;

    final leftHorn = Path()
      ..moveTo(0.39 * w, 0.34 * h)
      ..quadraticBezierTo(0.35 * w, 0.25 * h, 0.38 * w, 0.20 * h)
      ..quadraticBezierTo(0.43 * w, 0.26 * h, 0.45 * w, 0.33 * h)
      ..close();

    final rightHorn = Path()
      ..moveTo(0.61 * w, 0.34 * h)
      ..quadraticBezierTo(0.65 * w, 0.25 * h, 0.62 * w, 0.20 * h)
      ..quadraticBezierTo(0.57 * w, 0.26 * h, 0.55 * w, 0.33 * h)
      ..close();

    canvas.drawPath(leftHorn, hornFill);
    canvas.drawPath(leftHorn, hornStroke);
    canvas.drawPath(rightHorn, hornFill);
    canvas.drawPath(rightHorn, hornStroke);

    // Taring mungil
    final fangPaint = Paint()..color = Colors.white;
    final leftFang = Path()
      ..moveTo(0.455 * w, 0.67 * h)
      ..lineTo(0.478 * w, 0.67 * h)
      ..lineTo(0.466 * w, 0.705 * h)
      ..close();
    final rightFang = Path()
      ..moveTo(0.522 * w, 0.67 * h)
      ..lineTo(0.545 * w, 0.67 * h)
      ..lineTo(0.534 * w, 0.705 * h)
      ..close();
    canvas.drawPath(leftFang, fangPaint);
    canvas.drawPath(rightFang, fangPaint);
  }

  void _drawWitchHat(Canvas canvas, double w, double h) {
    canvas.save();
    canvas.translate(0.50 * w, 0.32 * h);
    canvas.rotate(-0.10);

    final hatPurple = Paint()..color = const Color(0xFF311B92);
    final hatOutline = Paint()
      ..color = const Color(0xFF1A0066)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeJoin = StrokeJoin.round;

    // Pinggiran lebar topi
    final brim = Rect.fromCenter(
      center: Offset.zero,
      width: w * 0.64,
      height: h * 0.12,
    );
    canvas.drawOval(brim, hatPurple);
    canvas.drawOval(brim, hatOutline);

    // Kerucut topi penyihir
    final cone = Path()
      ..moveTo(-0.19 * w, -0.01 * h)
      ..quadraticBezierTo(-0.08 * w, -0.16 * h, 0.07 * w, -0.24 * h)
      ..quadraticBezierTo(0.09 * w, -0.14 * h, 0.19 * w, -0.01 * h)
      ..close();
    canvas.drawPath(cone, hatPurple);
    canvas.drawPath(cone, hatOutline);

    // Sabuk emas & gesper
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -0.03 * h),
        width: w * 0.34,
        height: h * 0.04,
      ),
      Paint()..color = const Color(0xFFFFCA28),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -0.03 * h),
        width: w * 0.08,
        height: h * 0.055,
      ),
      Paint()
        ..color = const Color(0xFFFFF8E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016,
    );

    canvas.restore();

    // Kilau bintang kecil di kanan atas
    final starPaint = Paint()..color = const Color(0xFFFFCA28);
    final sx = 0.77 * w;
    final sy = 0.18 * h;
    final sr = w * 0.042;
    final star = Path()
      ..moveTo(sx, sy - sr)
      ..lineTo(sx + sr * 0.3, sy - sr * 0.3)
      ..lineTo(sx + sr, sy)
      ..lineTo(sx + sr * 0.3, sy + sr * 0.3)
      ..lineTo(sx, sy + sr)
      ..lineTo(sx - sr * 0.3, sy + sr * 0.3)
      ..lineTo(sx - sr, sy)
      ..lineTo(sx - sr * 0.3, sy - sr * 0.3)
      ..close();
    canvas.drawPath(star, starPaint);
  }

  @override
  bool shouldRepaint(covariant _CatFacePainter oldDelegate) {
    return oldDelegate.avatarId != avatarId || oldDelegate.catColor != catColor;
  }
}
