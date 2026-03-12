import 'package:badminton_app/app/theme.dart';
import 'package:flutter/material.dart';

/// 배드민턴 코트 배경 + 장식 라인.
///
/// 모든 Scaffold의 body를 이 위젯으로 감싼다.
/// 그라데이션 배경(#000000 → #2D5A27)과 코트 라인 장식을 제공한다.
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

/// 배드민턴 코트 경계선 장식.
///
/// design-system.md 기준:
/// - 좌측 경계선: x=22.5, width=2
/// - 우측 경계선: x=365.5, width=2
/// - 상단 서비스라인: y=44.19, height=2
/// - 하단 경계선: y=831.81, height=2
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 좌/우 경계선 (화면 기준 비율 적용)
    // Pencil 기준: 390px 폭에서 x=22.5, x=365.5
    final leftX = size.width * (22.5 / 390);
    final rightX = size.width * (365.5 / 390);

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

    // 상단 서비스라인 (Pencil 기준: y=44.19 / 844px)
    final topY = size.height * (44.19 / 844);
    canvas.drawLine(
      Offset(0, topY),
      Offset(size.width, topY),
      paint,
    );

    // 하단 경계선 (Pencil 기준: y=831.81 / 844px)
    final bottomY = size.height * (831.81 / 844);
    canvas.drawLine(
      Offset(0, bottomY),
      Offset(size.width, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
