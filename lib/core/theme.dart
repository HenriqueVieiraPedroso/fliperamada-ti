import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class ArcadeColors {
  static const bg = Color(0xFF0A0B1E);
  static const bg2 = Color(0xFF140B2E);
  static const surface = Color(0xFF14152C);
  static const cyan = Color(0xFF00F0FF);
  static const magenta = Color(0xFFFF2E93);
  static const lime = Color(0xFFB6FF3B);
  static const yellow = Color(0xFFFFD60A);
  static const red = Color(0xFFFF4D4D);
  static const purple = Color(0xFF8B5CF6);
  static const muted = Color(0xFF667085);
  static const divider = Color(0x3D667085);
  static const ink = Color(0xFFF5F6FF);
}

class ArcadeTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ArcadeColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: ArcadeColors.cyan,
          secondary: ArcadeColors.magenta,
          tertiary: ArcadeColors.lime,
          surface: ArcadeColors.surface,
          error: ArcadeColors.red,
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: ArcadeColors.ink),
          displayMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: ArcadeColors.ink),
          headlineLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: ArcadeColors.ink),
          headlineMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: ArcadeColors.ink),
          titleLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: ArcadeColors.ink),
          bodyLarge: TextStyle(fontFamily: 'Inter', color: ArcadeColors.ink),
          bodyMedium: TextStyle(fontFamily: 'Inter', color: ArcadeColors.ink),
          labelLarge:
              TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.045),
          hintStyle: const TextStyle(color: ArcadeColors.muted, fontSize: 13),
          labelStyle: const TextStyle(color: ArcadeColors.muted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: .09))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: .09))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: ArcadeColors.cyan, width: 1.2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ArcadeColors.red)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF202139),
          contentTextStyle: const TextStyle(color: ArcadeColors.ink),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        dividerColor: ArcadeColors.divider,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFEAF0F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF005A6B),
          onPrimary: Colors.white,
          secondary: Color(0xFFA50F56),
          onSecondary: Colors.white,
          tertiary: Color(0xFF365C00),
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF101828),
          error: Color(0xFFB42318),
          onError: Colors.white,
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828)),
          displayMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828)),
          headlineLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828)),
          headlineMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828)),
          titleLarge: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828)),
          bodyLarge: TextStyle(fontFamily: 'Inter', color: Color(0xFF101828)),
          bodyMedium: TextStyle(fontFamily: 'Inter', color: Color(0xFF101828)),
          labelLarge:
              TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          hintStyle: const TextStyle(color: Color(0xFF475467), fontSize: 13),
          labelStyle: const TextStyle(color: Color(0xFF344054)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF98A2B3), width: 1.1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF98A2B3), width: 1.1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF005A6B), width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFB42318))),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF172033),
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        dividerColor: const Color(0xFF98A2B3),
      );
}

class ThemeController extends ChangeNotifier {
  bool isDark = true;
  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;
  void toggle() {
    isDark = !isDark;
    notifyListeners();
  }
}

class GlassCard extends StatefulWidget {
  const GlassCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20),
      this.glow,
      this.borderRadius = 20,
      this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glow;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final glowColor = widget.glow ?? ArcadeColors.cyan;
    final entranceDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 420);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: entranceDuration,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
            offset: Offset(0, (1 - progress) * 7), child: child),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
              color: (widget.glow ?? Colors.white).withValues(
                  alpha: widget.glow == null
                      ? (_hovered ? .14 : .075)
                      : (_hovered ? .32 : .22))),
          boxShadow: widget.glow == null && !_hovered
              ? const []
              : [
                  BoxShadow(
                      color: glowColor.withValues(alpha: _hovered ? .11 : .07),
                      blurRadius: _hovered ? 34 : 28,
                      spreadRadius: -5)
                ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: Colors.white.withValues(alpha: .045),
              child: InkWell(
                onTap: widget.onTap,
                onHover: (hovering) {
                  if (_hovered != hovering) {
                    setState(() => _hovered = hovering);
                  }
                },
                borderRadius: radius,
                hoverColor: glowColor.withValues(alpha: .035),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  const NeonButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.danger = false,
      this.compact = false,
      this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;
  final bool compact;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = danger
        ? const [ArcadeColors.red, Color(0xFFFF2E68)]
        : const [ArcadeColors.cyan, ArcadeColors.purple];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
              color: colors.first.withValues(alpha: .19),
              blurRadius: 22,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: busy ? null : onPressed,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 13 : 18, vertical: compact ? 10 : 13),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (busy) ...[
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)),
                const SizedBox(width: 9)
              ],
              if (!busy && icon != null) ...[
                Icon(icon, size: 17, color: Colors.white),
                const SizedBox(width: 8)
              ],
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 12 : 13,
                      letterSpacing: .35)),
            ]),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(
      {super.key, required this.label, required this.color, this.dot = true});
  final String label;
  final Color color;
  final bool dot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) ...[_StatusChipDot(color: color), const SizedBox(width: 7)],
          Flexible(
              child: Text(label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7))),
        ]),
      );
}

class _StatusChipDot extends StatefulWidget {
  const _StatusChipDot({required this.color});
  final Color color;

  @override
  State<_StatusChipDot> createState() => _StatusChipDotState();
}

class _StatusChipDotState extends State<_StatusChipDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _scale = Tween<double>(begin: .9, end: 1.08)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (disabled == _animationsDisabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _controller
        ..stop()
        ..value = .5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: widget.color.withValues(
                          alpha: _animationsDisabled == true ? .5 : .45),
                      blurRadius: 7)
                ]),
            child: const SizedBox(width: 6, height: 6),
          ),
        ),
      );
}

class PageTitle extends StatelessWidget {
  const PageTitle(
      {super.key, required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final heading =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 25, letterSpacing: -.6)),
            const SizedBox(height: 5),
            Text(subtitle,
                style:
                    const TextStyle(color: ArcadeColors.muted, fontSize: 12)),
          ]);
          if (constraints.maxWidth < 600) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading,
                  if (trailing != null) ...[
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: trailing!),
                  ],
                ]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: heading),
            if (trailing != null) trailing!,
          ]);
        },
      );
}

class Sparkline extends StatelessWidget {
  const Sparkline(
      {super.key, required this.values, required this.color, this.height = 28});
  final List<double> values;
  final Color color;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      child: CustomPaint(
          painter: _SparkPainter(values, color), size: Size.infinite));
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);
  final List<double> values;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = (max - min).abs() < .01 ? 1 : max - min;
    final points = List.generate(
        values.length,
        (i) => Offset(size.width * i / (values.length - 1),
            size.height - 3 - ((values[i] - min) / range) * (size.height - 8)));
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final mid = (prev.dx + current.dx) / 2;
      path.cubicTo(mid, prev.dy, mid, current.dy, current.dx, current.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .13)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(points.last, 2.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
