import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/gen_l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Draggable floating action button shown on top of the main scaffold.
///
/// Appears on every tab of [MainScreen] (single global mount in the shell's
/// `body: Stack`). The user can long-press / drag the button anywhere inside
/// the safe area of the body stack; on release the button animates toward
/// the nearest horizontal edge so it never rests halfway over content.
///
/// On first appearance a small hint bubble is shown next to the button (with
/// a triangle pointing at it) to teach users the drag affordance. The hint
/// is dismissed permanently as soon as the user starts dragging.
class AiFloatingButton extends StatefulWidget {
  /// When false, the button renders nothing.
  final bool visible;

  const AiFloatingButton({super.key, this.visible = true});

  @override
  State<AiFloatingButton> createState() => _AiFloatingButtonState();
}

class _AiFloatingButtonState extends State<AiFloatingButton>
    with SingleTickerProviderStateMixin {
  /// Width/height of the visible circular button.
  static const double _fabSize = 56;

  /// Distance from the edge that the button snaps to.
  static const double _edgeInset = 16;

  /// Safe-area padding for the AppBar (top) and BottomAppBar (bottom).
  static const double _topSafePadding = 8;
  static const double _bottomSafePadding = 80;

  /// Total accumulated pan delta in logical pixels. Used to disambiguate
  /// tap (delta < [_tapThreshold]) vs drag.
  static const double _tapThreshold = 4;

  /// Animation duration for the snap-to-edge motion.
  static const Duration _snapDuration = Duration(milliseconds: 220);

  /// Distance from the bottom-right corner the button initially rests at.
  static const double _defaultBottomInset = 80;

  /// Small gap between the FAB and the hint bubble.
  static const double _hintGap = 6;

  Offset? _offset;
  double _panDistance = 0;
  bool _hasDragged = false;
  bool _hintVisible = true;

  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: _snapDuration,
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  Offset _defaultOffsetFor(Size bounds) => Offset(
        bounds.width - _fabSize - _edgeInset,
        bounds.height - _fabSize - _defaultBottomInset,
      );

  void _onPanStart(DragStartDetails details) {
    _snapController.stop();
    _panDistance = 0;
    if (!_hasDragged) {
      setState(() {
        _hasDragged = true;
        _hintVisible = false;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size bounds) {
    _panDistance += details.delta.distance;
    setState(() {
      _offset = _clamp(
        (_offset ?? _defaultOffsetFor(bounds)) + details.delta,
        bounds,
      );
    });
  }

  void _onPanEnd(DragEndDetails details, Size bounds) {
    if (_panDistance < _tapThreshold) {
      _panDistance = 0;
      _onTap();
      return;
    }
    _panDistance = 0;
    _animateToEdge(bounds);
  }

  void _onTap() {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.authRequiredTitle),
            action: SnackBarAction(
              label: l10n.signIn,
              onPressed: () => GoRouter.of(context).push(AppRoutes.login),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    GoRouter.of(context).push(AppRoutes.aiAssistant);
  }

  Offset _clamp(Offset candidate, Size bounds) {
    final maxX = (bounds.width - _fabSize - _edgeInset)
        .clamp(_edgeInset, double.infinity)
        .toDouble();
    const minY = _topSafePadding;
    final maxY = (bounds.height - _fabSize - _bottomSafePadding)
        .clamp(minY, double.infinity)
        .toDouble();
    return Offset(
      candidate.dx.clamp(_edgeInset, maxX),
      candidate.dy.clamp(minY, maxY),
    );
  }

  void _animateToEdge(Size bounds) {
    final current = _offset ?? _defaultOffsetFor(bounds);
    final centerX = current.dx + _fabSize / 2;
    final targetX = centerX < bounds.width / 2
        ? _edgeInset
        : bounds.width - _fabSize - _edgeInset;
    final target = Offset(targetX, current.dy);

    if (target == current) return;

    _snapAnimation = Tween<Offset>(begin: current, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController
      ..reset()
      ..addListener(_onSnapTick)
      ..forward();
  }

  void _onSnapTick() {
    final value = _snapAnimation?.value;
    if (value != null && mounted) {
      setState(() => _offset = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounds = Size(constraints.maxWidth, constraints.maxHeight);
        final current = _offset ?? _defaultOffsetFor(bounds);
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context);

        final fabCenterX = current.dx + _fabSize / 2;
        final fabCenterY = current.dy + _fabSize / 2;

        final fabOnRightHalf = fabCenterX >= bounds.width / 2;

        // Vertically center the hint on the FAB.
        final textStyle = TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: 1.2,
        );

        // Hint pill dimensions.
        const hintWidth = 160.0;
        const hintHeight = 36.0;

        // Bubble top: center vertically on the FAB, clamped to safe top.
        final hintTop = (fabCenterY - hintHeight / 2)
            .clamp(_topSafePadding, double.infinity)
            .toDouble();

        // Horizontal position: place the hint box with a [_hintGap] between
        // the hint box edge and the FAB edge. The arrow fills the remaining
        // visual space so bubble + arrow + FAB read as a single connected unit.
        final double hintLeft;
        if (fabOnRightHalf) {
          // Bubble to the left of FAB. Box right edge = fabLeft - gap.
          // The arrow then "sticks out" from box right edge toward the FAB.
          hintLeft = (current.dx - _hintGap) - hintWidth;
        } else {
          // Bubble to the right of FAB. Box left edge = fabRight + gap.
          hintLeft = current.dx + _fabSize + _hintGap;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (_hintVisible)
              Positioned(
                left: hintLeft,
                top: hintTop,
                child: IgnorePointer(
                  child: _HintBubble(
                    width: hintWidth,
                    height: hintHeight,
                    arrowSide: fabOnRightHalf
                        ? _HintBubbleArrowSide.right
                        : _HintBubbleArrowSide.left,
                    color: colorScheme.surfaceContainerHigh,
                    foreground: colorScheme.onSurface,
                    text: l10n.aiFloatingHintText,
                    textStyle: textStyle,
                  ),
                ),
              ),
            Positioned(
              left: current.dx,
              top: current.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: (d) => _onPanUpdate(d, bounds),
                onPanEnd: (d) => _onPanEnd(d, bounds),
                child: Semantics(
                  label: l10n.aiFloatingOpenTooltip,
                  button: true,
                  child: Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    color: colorScheme.primary,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _onTap,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Direction the arrow on the hint bubble points toward.
enum _HintBubbleArrowSide { left, right }

/// A polished hint bubble: pill-shaped container (no border, soft shadow)
/// with a small arrow pointing at the FAB.
///
/// The arrow is drawn outside the pill body using [CustomPaint], so the pill
/// itself stays a clean rounded rectangle. A subtle drop shadow lifts the
/// bubble off the background for visual clarity.
class _HintBubble extends StatelessWidget {
  final double width;
  final double height;
  final _HintBubbleArrowSide arrowSide;
  final Color color;
  final Color foreground;
  final String text;
  final TextStyle textStyle;

  const _HintBubble({
    required this.width,
    required this.height,
    required this.arrowSide,
    required this.color,
    required this.foreground,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _HintBubblePainter(
          color: color,
          arrowSide: arrowSide,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class _HintBubblePainter extends CustomPainter {
  final Color color;
  final _HintBubbleArrowSide arrowSide;

  static const double _radius = 18.0;
  static const double _arrowSize = 7.0;

  _HintBubblePainter({
    required this.color,
    required this.arrowSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- Soft drop shadow for depth ---
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 2, size.width, size.height),
      const Radius.circular(_radius),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // --- Pill background ---
    final fillPaint = Paint()..color = color;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(_radius),
    );
    canvas.drawRRect(pillRect, fillPaint);

    // --- Small arrow connector ---
    // Drawn as a filled circle that slightly overlaps the pill edge,
    // creating a smooth "stem" connecting the bubble to the FAB.
    // This avoids the sharp-corner issue of a triangle overlay.
    final arrowPaint = Paint()..color = color;

    final double arrowX;
    if (arrowSide == _HintBubbleArrowSide.right) {
      arrowX = size.width + _arrowSize - 1;
    } else {
      arrowX = -(_arrowSize - 1);
    }

    // Draw the arrow as a small filled circle (creates a smooth dot-stem).
    canvas.drawCircle(
      Offset(arrowX, size.height / 2),
      _arrowSize / 2,
      arrowPaint,
    );

    // Soft shadow under the arrow dot to keep it grounded.
    final arrowShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(arrowX + 0.5, size.height / 2 + 1),
      _arrowSize / 2,
      arrowShadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HintBubblePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.arrowSide != arrowSide;
}
