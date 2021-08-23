import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minimalistic_push/control/background_controller.dart';
import 'package:minimalistic_push/control/session_controller.dart';
import 'package:minimalistic_push/models/peaks.dart';

/// This Widget represents the background of the application.
class Background extends StatelessWidget {
  /// The constructor.
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints.expand(),
        color: Theme.of(context).accentColor,
        alignment: Alignment.bottomCenter,
        child: GetBuilder<SessionController>(
          builder: (sessionController) => GetBuilder<BackgroundController>(
            builder: (backgroundcontroller) => _AnimatedPeaks(
              peaks: Peaks(list: sessionController.normalized.toList()),
              factor: backgroundcontroller.factor.toDouble(),
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOutQuart,
            ),
          ),
        ),
      );
}

/// TODO: Performance optimization.
class _AnimatedPeaks extends ImplicitlyAnimatedWidget {
  final Peaks peaks;
  final double factor;

  _AnimatedPeaks({
    Key? key,
    required this.peaks,
    required this.factor,
    required Duration duration,
    Curve curve = Curves.linear,
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedPeaksState();
}

class _AnimatedPeaksState extends AnimatedWidgetBaseState<_AnimatedPeaks> {
  PeaksTween? _peaksTween;
  Tween<double>? _factorTween;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _CurvePainter(
          peaks: _peaksTween!.evaluate(animation),
          context: context,
          factor: _factorTween!.evaluate(animation),
        ),
        size: MediaQuery.of(context).size,
      );

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _peaksTween = visitor(
      _peaksTween,
      widget.peaks,
      (dynamic value) => PeaksTween(begin: value),
    ) as PeaksTween;
    _factorTween = visitor(
      _factorTween,
      widget.factor,
      (dynamic value) => Tween<double>(begin: value),
    ) as Tween<double>;
  }
}

class _CurvePainter extends CustomPainter {
  final _paint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 0.0;

  late double spaceOnTop;

  _CurvePainter({
    required this.peaks,
    required this.context,
    required this.factor,
  });

  final Peaks peaks;
  final BuildContext context;
  final double factor;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = Theme.of(context).primaryColor;

    var height = size.height * 0.2;
    spaceOnTop = size.height - size.height * (factor);

    var steps = peaks.list.length * 2 - 2;
    var stepWidth = size.width / steps;

    if (spaceOnTop >= size.height * 0.8) {
      height = size.height - spaceOnTop;
    } else if (spaceOnTop <= size.height * 0.2) {
      height = spaceOnTop;
    }

    var path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(0.0, _getHeight(height, peaks.list.first));

    var offset = 0;
    for (var i = 0; i < peaks.list.length - 1; i++) {
      path.cubicTo(stepWidth * (offset + i + 1), _getHeight(height, peaks.list[i]), stepWidth * (offset + i + 1),
          _getHeight(height, peaks.list[i + 1]), stepWidth * (offset + i + 2), _getHeight(height, peaks.list[i + 1]));
      offset++;
    }

    path.lineTo(size.width, _getHeight(height, peaks.list.last));
    path.lineTo(size.width, size.height);

    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double _getHeight(double height, double factor) => (height - height * factor) + spaceOnTop;
}
