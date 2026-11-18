import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Avatar preset untuk pemilik akun Catlendar.
///
/// Ilustrasi digambar langsung menggunakan Canvas sehingga tidak membutuhkan
/// file PNG/JPG untuk setiap owner avatar. Nilai [avatarId] tetap disimpan
/// sebagai string (contoh: owner_1) di Firestore.
class OwnerAvatar extends StatelessWidget {
  const OwnerAvatar({
    super.key,
    required this.avatarId,
  });

  final String avatarId;

  /// True jika [avatarId] punya gambar di widget ini (owner_1 sampai owner_8).
  /// Id lain (mis. avatar kucing) tidak didukung dan akan jatuh ke owner_1.
  static bool supports(String avatarId) =>
      _OwnerAvatarPainter.supports(avatarId);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OwnerAvatarPainter(avatarId: avatarId),
      child: const SizedBox.expand(),
    );
  }
}

class _OwnerAvatarStyle {
  const _OwnerAvatarStyle({
    required this.background,
    required this.skin,
    required this.hair,
    required this.shirt,
    required this.hairStyle,
    this.hasGlasses = false,
    this.accessory = _OwnerAccessory.none,
  });

  final Color background;
  final Color skin;
  final Color hair;
  final Color shirt;
  final int hairStyle;
  final bool hasGlasses;
  final _OwnerAccessory accessory;
}

enum _OwnerAccessory { none, bow, flower, headband, cap, star }

class _OwnerAvatarPainter extends CustomPainter {
  const _OwnerAvatarPainter({required this.avatarId});

  final String avatarId;

  static const _styles = <String, _OwnerAvatarStyle>{
    'owner_1': _OwnerAvatarStyle(
      background: Color(0xFFFFE9D8),
      skin: Color(0xFFD99E78),
      hair: Color(0xFF8A5038),
      shirt: Color(0xFFE8AD55),
      hairStyle: 2,
    ),
    'owner_2': _OwnerAvatarStyle(
      background: Color(0xFFDDF3EC),
      skin: Color(0xFFF5D2B2),
      hair: Color(0xFF282329),
      shirt: Color(0xFF65B7A5),
      hairStyle: 1,
      hasGlasses: true,
    ),
    'owner_3': _OwnerAvatarStyle(
      background: Color(0xFFEDE3FA),
      skin: Color(0xFFF2C7A5),
      hair: Color(0xFF49302A),
      shirt: Color(0xFF9C83C8),
      hairStyle: 0,
      accessory: _OwnerAccessory.flower,
    ),
    'owner_4': _OwnerAvatarStyle(
      background: Color(0xFFDDEBFA),
      skin: Color(0xFF9D674D),
      hair: Color(0xFF302522),
      shirt: Color(0xFFE58D83),
      hairStyle: 3,
      accessory: _OwnerAccessory.star,
    ),
    'owner_5': _OwnerAvatarStyle(
      background: Color(0xFFF9E1EA),
      skin: Color(0xFFE8B99A),
      hair: Color(0xFF392A27),
      shirt: Color(0xFF8EADD5),
      hairStyle: 4,
      accessory: _OwnerAccessory.bow,
    ),
    'owner_6': _OwnerAvatarStyle(
      background: Color(0xFFFFF2CC),
      skin: Color(0xFFC58B68),
      hair: Color(0xFF4A3025),
      shirt: Color(0xFF80B99A),
      hairStyle: 5,
      accessory: _OwnerAccessory.headband,
    ),
    'owner_7': _OwnerAvatarStyle(
      background: Color(0xFFE9E3F8),
      skin: Color(0xFFF0C9A8),
      hair: Color(0xFFB76D3D),
      shirt: Color(0xFFD98DAA),
      hairStyle: 6,
    ),
    'owner_8': _OwnerAvatarStyle(
      background: Color(0xFFDDF0F5),
      skin: Color(0xFFB77F61),
      hair: Color(0xFF29252B),
      shirt: Color(0xFF789CB8),
      hairStyle: 7,
      hasGlasses: true,
      accessory: _OwnerAccessory.cap,
    ),
  };

  static bool supports(String avatarId) => _styles.containsKey(avatarId);

  _OwnerAvatarStyle get _style => _styles[avatarId] ?? _styles['owner_1']!;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final s = _style;
    final outline = Paint()
      ..color = const Color(0xFF493B43).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014;

    // Lingkaran latar pastel.
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.5,
      Paint()..color = s.background,
    );

    // Rambut bagian belakang, leher, dan badan.
    _drawHairBack(canvas, w, h, s);
    _drawNeck(canvas, w, h, s);
    _drawClothes(canvas, w, h, s);

    // Telinga dan wajah.
    final earPaint = Paint()..color = s.skin;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.285, h * 0.505),
        width: w * 0.105,
        height: h * 0.16,
      ),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.715, h * 0.505),
        width: w * 0.105,
        height: h * 0.16,
      ),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.485),
        width: w * 0.43,
        height: h * 0.54,
      ),
      Paint()..color = s.skin,
    );

    // Rambut depan dan poni.
    _drawHairFront(canvas, w, h, s);

    // Mata dan alis.
    final eyeY = h * 0.50;
    final eyeRadius = w * 0.022;
    final eyePaint = Paint()..color = const Color(0xFF342A2C);
    for (final x in [w * 0.415, w * 0.585]) {
      canvas.drawCircle(Offset(x, eyeY), eyeRadius, eyePaint);
      canvas.drawCircle(
        Offset(x - eyeRadius * 0.28, eyeY - eyeRadius * 0.3),
        eyeRadius * 0.28,
        Paint()..color = Colors.white,
      );
    }
    _drawBrows(canvas, w, h);

    // Pipi, hidung, dan senyum.
    final cheekPaint = Paint()..color = const Color(0xFFE98991).withValues(alpha: 0.34);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.345, h * 0.565), width: w * 0.085, height: h * 0.04),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.655, h * 0.565), width: w * 0.085, height: h * 0.04),
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.565),
      w * 0.018,
      Paint()..color = const Color(0xFFB96C70),
    );
    final smile = Path()
      ..moveTo(w * 0.455, h * 0.605)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w * 0.545, h * 0.605);
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF74464A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round,
    );

    if (s.hasGlasses) _drawGlasses(canvas, w, h);
    _drawAccessory(canvas, w, h, s);

    // Garis luar tipis agar bentuk tetap terbaca pada ukuran kecil.
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.49, outline);
  }

  void _drawNeck(Canvas canvas, double w, double h, _OwnerAvatarStyle s) {
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.425, h * 0.67, w * 0.15, h * 0.19),
      Radius.circular(w * 0.045),
    );
    canvas.drawRRect(neck, Paint()..color = s.skin);
  }

  void _drawClothes(Canvas canvas, double w, double h, _OwnerAvatarStyle s) {
    final shoulders = Path()
      ..moveTo(w * 0.08, h)
      ..quadraticBezierTo(w * 0.12, h * 0.80, w * 0.34, h * 0.78)
      ..lineTo(w * 0.43, h * 0.735)
      ..quadraticBezierTo(w * 0.5, h * 0.79, w * 0.57, h * 0.735)
      ..lineTo(w * 0.66, h * 0.78)
      ..quadraticBezierTo(w * 0.88, h * 0.80, w * 0.92, h)
      ..close();
    canvas.drawPath(shoulders, Paint()..color = s.shirt);

    // Kerah kecil.
    final collar = Path()
      ..moveTo(w * 0.405, h * 0.77)
      ..lineTo(w * 0.5, h * 0.855)
      ..lineTo(w * 0.595, h * 0.77)
      ..lineTo(w * 0.55, h * 0.75)
      ..lineTo(w * 0.5, h * 0.80)
      ..lineTo(w * 0.45, h * 0.75)
      ..close();
    canvas.drawPath(collar, Paint()..color = Colors.white.withValues(alpha: 0.72));
  }

  void _drawHairBack(Canvas canvas, double w, double h, _OwnerAvatarStyle s) {
    final p = Paint()..color = s.hair;
    switch (s.hairStyle) {
      case 0: // Bob cut
        final path = Path()
          ..moveTo(w * 0.27, h * 0.51)
          ..lineTo(w * 0.24, h * 0.33)
          ..quadraticBezierTo(w * 0.24, h * 0.10, w * 0.5, h * 0.105)
          ..quadraticBezierTo(w * 0.77, h * 0.10, w * 0.76, h * 0.34)
          ..lineTo(w * 0.73, h * 0.69)
          ..quadraticBezierTo(w * 0.67, h * 0.77, w * 0.63, h * 0.67)
          ..lineTo(w * 0.37, h * 0.67)
          ..quadraticBezierTo(w * 0.33, h * 0.77, w * 0.27, h * 0.69)
          ..close();
        canvas.drawPath(path, p);
        break;
      case 1: // Rambut panjang bergelombang
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.25, w * 0.56, h * 0.57), Radius.circular(w * 0.2)),
          p,
        );
        break;
      case 2: // Medium hair
        canvas.drawOval(Rect.fromLTWH(w * 0.235, h * 0.11, w * 0.53, h * 0.49), p);
        break;
      case 3: // Curly / afro
        for (final point in <Offset>[
          Offset(w * .31, h * .27), Offset(w * .40, h * .17),
          Offset(w * .50, h * .14), Offset(w * .60, h * .17),
          Offset(w * .69, h * .27), Offset(w * .28, h * .39),
          Offset(w * .72, h * .39),
        ]) {
          canvas.drawCircle(point, w * .105, p);
        }
        break;
      case 4: // Two buns
        canvas.drawOval(Rect.fromLTWH(w * .22, h * .12, w * .20, h * .23), p);
        canvas.drawOval(Rect.fromLTWH(w * .58, h * .12, w * .20, h * .23), p);
        canvas.drawOval(Rect.fromLTWH(w * .25, h * .18, w * .50, h * .42), p);
        break;
      case 5: // Long side-swept
        final path = Path()
          ..moveTo(w * .24, h * .52)
          ..quadraticBezierTo(w * .13, h * .16, w * .51, h * .10)
          ..quadraticBezierTo(w * .85, h * .10, w * .78, h * .49)
          ..lineTo(w * .78, h * .79)
          ..lineTo(w * .68, h * .72)
          ..lineTo(w * .32, h * .72)
          ..lineTo(w * .22, h * .79)
          ..close();
        canvas.drawPath(path, p);
        break;
      case 6: // Short pixie cut
        canvas.drawOval(Rect.fromLTWH(w * .25, h * .12, w * .50, h * .42), p);
        break;
      case 7: // Short textured hair
        canvas.drawOval(Rect.fromLTWH(w * .23, h * .12, w * .54, h * .43), p);
        for (final point in <Offset>[
          Offset(w * .32, h * .23), Offset(w * .43, h * .16),
          Offset(w * .55, h * .15), Offset(w * .67, h * .23),
        ]) {
          canvas.drawCircle(point, w * .055, p);
        }
        break;
    }
  }

  void _drawHairFront(Canvas canvas, double w, double h, _OwnerAvatarStyle s) {
    final p = Paint()..color = s.hair;
    switch (s.hairStyle) {
      case 0:
        final fringe = Path()
          ..moveTo(w * .26, h * .39)
          ..quadraticBezierTo(w * .31, h * .08, w * .57, h * .17)
          ..quadraticBezierTo(w * .48, h * .30, w * .37, h * .36)
          ..quadraticBezierTo(w * .31, h * .38, w * .26, h * .39)
          ..close();
        canvas.drawPath(fringe, p);
        break;
      case 1:
        canvas.drawOval(Rect.fromLTWH(w * .28, h * .13, w * .43, h * .22), p);
        canvas.drawCircle(Offset(w * .31, h * .31), w * .07, p);
        canvas.drawCircle(Offset(w * .69, h * .30), w * .07, p);
        break;
      case 2:
        final fringe = Path()
          ..moveTo(w * .25, h * .39)
          ..quadraticBezierTo(w * .34, h * .15, w * .55, h * .19)
          ..quadraticBezierTo(w * .66, h * .20, w * .74, h * .37)
          ..quadraticBezierTo(w * .61, h * .31, w * .55, h * .34)
          ..quadraticBezierTo(w * .42, h * .28, w * .25, h * .39)
          ..close();
        canvas.drawPath(fringe, p);
        break;
      case 3:
        for (final point in <Offset>[
          Offset(w * .34, h * .30), Offset(w * .43, h * .22),
          Offset(w * .52, h * .21), Offset(w * .62, h * .27),
        ]) {
          canvas.drawCircle(point, w * .085, p);
        }
        break;
      case 4:
        canvas.drawOval(Rect.fromLTWH(w * .27, h * .18, w * .46, h * .22), p);
        break;
      case 5:
        final fringe = Path()
          ..moveTo(w * .24, h * .40)
          ..quadraticBezierTo(w * .32, h * .11, w * .70, h * .20)
          ..quadraticBezierTo(w * .61, h * .24, w * .56, h * .34)
          ..quadraticBezierTo(w * .39, h * .29, w * .24, h * .40)
          ..close();
        canvas.drawPath(fringe, p);
        break;
      case 6:
        final fringe = Path()
          ..moveTo(w * .25, h * .38)
          ..quadraticBezierTo(w * .29, h * .11, w * .59, h * .16)
          ..quadraticBezierTo(w * .70, h * .19, w * .74, h * .34)
          ..lineTo(w * .62, h * .31)
          ..lineTo(w * .53, h * .37)
          ..lineTo(w * .43, h * .31)
          ..close();
        canvas.drawPath(fringe, p);
        break;
      case 7:
        // Poni pendek yang membentuk siluet playful.
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * .29, h * .20, w * .42, h * .14), Radius.circular(w * .08)),
          p,
        );
        break;
    }
  }

  void _drawBrows(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = const Color(0xFF49302A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .014
      ..strokeCap = StrokeCap.round;
    for (final x in [w * .415, w * .585]) {
      final brow = Path()
        ..moveTo(x - w * .035, h * .445)
        ..quadraticBezierTo(x, h * .425, x + w * .035, h * .445);
      canvas.drawPath(brow, paint);
    }
  }

  void _drawGlasses(Canvas canvas, double w, double h) {
    final p = Paint()
      ..color = const Color(0xFF51425B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .018;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * .415, h * .50), width: w * .14, height: h * .105), Radius.circular(w * .035)),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * .585, h * .50), width: w * .14, height: h * .105), Radius.circular(w * .035)),
      p,
    );
    canvas.drawLine(Offset(w * .485, h * .495), Offset(w * .515, h * .495), p);
  }

  void _drawAccessory(Canvas canvas, double w, double h, _OwnerAvatarStyle s) {
    switch (s.accessory) {
      case _OwnerAccessory.none:
        return;
      case _OwnerAccessory.bow:
        final bowPaint = Paint()..color = const Color(0xFFE879A5);
        final bow = Path()
          ..moveTo(w * .68, h * .19)
          ..lineTo(w * .58, h * .13)
          ..lineTo(w * .59, h * .25)
          ..close()
          ..moveTo(w * .68, h * .19)
          ..lineTo(w * .78, h * .13)
          ..lineTo(w * .77, h * .25)
          ..close();
        canvas.drawPath(bow, bowPaint);
        canvas.drawCircle(Offset(w * .68, h * .19), w * .025, Paint()..color = const Color(0xFFFFD6E5));
        break;
      case _OwnerAccessory.flower:
        final center = Offset(w * .72, h * .31);
        final petal = Paint()..color = const Color(0xFFFFA9B9);
        for (var i = 0; i < 5; i++) {
          final angle = i * 1.256637;
          canvas.drawCircle(
            Offset(center.dx + w * .045 * math.cos(angle), center.dy + h * .045 * math.sin(angle)),
            w * .035,
            petal,
          );
        }
        canvas.drawCircle(center, w * .027, Paint()..color = const Color(0xFFFFD35A));
        break;
      case _OwnerAccessory.headband:
        final band = Path()
          ..moveTo(w * .29, h * .32)
          ..quadraticBezierTo(w * .5, h * .08, w * .71, h * .32);
        canvas.drawPath(
          band,
          Paint()
            ..color = const Color(0xFFF2A7B8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * .035
            ..strokeCap = StrokeCap.round,
        );
        break;
      case _OwnerAccessory.cap:
        final cap = Path()
          ..moveTo(w * .25, h * .31)
          ..quadraticBezierTo(w * .30, h * .13, w * .52, h * .14)
          ..quadraticBezierTo(w * .72, h * .14, w * .76, h * .32)
          ..quadraticBezierTo(w * .50, h * .27, w * .25, h * .31)
          ..close();
        canvas.drawPath(cap, Paint()..color = const Color(0xFF6685A8));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * .57, h * .30), width: w * .38, height: h * .055),
          Paint()..color = const Color(0xFF8FA9C7),
        );
        break;
      case _OwnerAccessory.star:
        final center = Offset(w * .72, h * .27);
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final radius = i.isEven ? w * .055 : w * .025;
          final angle = -1.5708 + i * 0.6283;
          final point = Offset(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
          if (i == 0) {
            star.moveTo(point.dx, point.dy);
          } else {
            star.lineTo(point.dx, point.dy);
          }
        }
        star.close();
        canvas.drawPath(star, Paint()..color = const Color(0xFFFFC857));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _OwnerAvatarPainter oldDelegate) {
    return oldDelegate.avatarId != avatarId;
  }
}

