import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';

/// 배드민턴 코트 배경 + 장식 라인.
///
/// 모든 Scaffold의 body를 이 위젯으로 감싼다.
/// 단색 배경(#1B5E30)과 코트 라인 장식을 제공한다.
class CourtBackground extends StatelessWidget {
  const CourtBackground({
    super.key,
    required this.child,
    this.showCourtLines = true,
  });

  final Widget child;
  final bool showCourtLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: showCourtLines
          ? Stack(
              children: [
                const _CourtLines(),
                child,
              ],
            )
          : child,
    );
  }
}

/// 배드민턴 코트 경계선 장식 (배경 전용).
///
/// 좌우 라인을 화면 가장자리(8px)로 밀어 컨텐츠와 겹치지 않게 하고,
/// 불투명도를 낮춰 은은한 배경 장식으로만 보이도록 한다.
class _CourtLines extends StatelessWidget {
  const _CourtLines();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CourtLinePainter(),
        ),
      ),
    );
  }
}

class _CourtLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.courtLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 좌/우 경계선 — 화면 가장자리 8px 위치 (컨텐츠 패딩 28px보다 충분히 바깥)
    const edgeInset = 8.0;
    final leftX = edgeInset;
    final rightX = size.width - edgeInset;

    // 좌측 경계선
    canvas.drawLine(
      Offset(leftX, 0),
      Offset(leftX, size.height),
      paint,
    );

    // 우측 경계선
    canvas.drawLine(
      Offset(rightX, 0),
      Offset(rightX, size.height),
      paint,
    );

    // 상하 경계선
    final inset = size.height * (12.19 / 844);
    final topY = inset;
    final bottomY = size.height - inset;

    canvas.drawLine(
      Offset(0, topY),
      Offset(size.width, topY),
      paint,
    );

    canvas.drawLine(
      Offset(0, bottomY),
      Offset(size.width, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
