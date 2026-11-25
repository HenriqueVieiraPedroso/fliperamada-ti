import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'money.dart';
import 'theme.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
String money(num value) => _currency.format(value);
String shortDate(DateTime? value) =>
    value == null ? '—' : DateFormat('dd/MM/yyyy', 'pt_BR').format(value);
String shortTime(DateTime value) => DateFormat('HH:mm', 'pt_BR').format(value);

double? _kpiNumericValue(String value) {
  if (value.contains('R\$')) return parseMoney(value);
  final trimmed = value.trim();
  final percent = RegExp(r'^(-?\d+(?:[,.]\d+)?)\s*%$').firstMatch(trimmed);
  if (percent != null) {
    return double.tryParse(percent.group(1)!.replaceAll(',', '.'));
  }
  return int.tryParse(trimmed)?.toDouble();
}

String _countedKpiValue(String value, double progress) {
  final numeric = _kpiNumericValue(value);
  if (numeric == null || !numeric.isFinite) return value;
  if (value.contains('R\$')) return money(numeric * progress);
  final trimmed = value.trim();
  final percent = RegExp(r'^(-?\d+(?:[,.]\d+)?)\s*%$').firstMatch(trimmed);
  if (percent != null) {
    final numberText = percent.group(1)!;
    final separator = RegExp(r'[,.]').firstMatch(numberText);
    final precision =
        separator == null ? 0 : numberText.length - separator.start - 1;
    return '${(numeric * progress).toStringAsFixed(precision)}%';
  }
  return (numeric * progress).round().toString();
}

class KpiCard extends StatelessWidget {
  const KpiCard(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.change,
      required this.icon,
      required this.spark});
  final String label;
  final String value;
  final Color color;
  final String change;
  final IconData icon;
  final List<double> spark;
  @override
  Widget build(BuildContext context) {
    final disabled = MediaQuery.disableAnimationsOf(context);
    final changeText = change.trim();
    final isPercentChange = changeText.endsWith('%');
    final changeAmount = isPercentChange
        ? double.tryParse(changeText
            .substring(0, changeText.length - 1)
            .trim()
            .replaceAll(',', '.'))
        : null;
    final isNegativeChange = changeAmount != null && changeAmount < 0;
    final changeColor = isNegativeChange ? ArcadeColors.red : ArcadeColors.lime;
    final changeIcon = isNegativeChange
        ? Icons.trending_down_rounded
        : Icons.trending_up_rounded;

    return GlassCard(
      glow: color,
      padding: const EdgeInsets.fromLTRB(18, 17, 17, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: ArcadeColors.muted,
                      fontWeight: FontWeight.w800))),
          Icon(icon, size: 17, color: color.withValues(alpha: .92)),
        ]),
        const SizedBox(height: 13),
        TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration:
                disabled ? Duration.zero : const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              final progress = disabled ? 1.0 : t;
              return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                      offset: Offset(0, disabled ? 0 : (1 - t) * 7),
                      child: Text(_countedKpiValue(value, progress),
                          style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.8))));
            }),
        const SizedBox(height: 11),
        LayoutBuilder(builder: (context, constraints) {
          final showSparkline = constraints.maxWidth >= 210;
          return Row(children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(changeIcon, size: 12, color: changeColor),
                  const SizedBox(width: 2),
                  Text(change,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: changeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800))
                ])),
            if (showSparkline) ...[
              const SizedBox(width: 7),
              if (isPercentChange)
                const Expanded(
                    child: Text('vs. período anterior',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: ArcadeColors.muted, fontSize: 9)))
              else
                const Spacer(),
              SizedBox(
                  width: 72,
                  child: Sparkline(values: spark, color: color, height: 23)),
            ],
          ]);
        }),
      ]),
    );
  }
}

class PanelHeading extends StatelessWidget {
  const PanelHeading(this.title, {super.key, this.trailing, this.subtitle});
  final String title;
  final Widget? trailing;
  final String? subtitle;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(color: ArcadeColors.muted, fontSize: 10))
          ],
        ])),
        if (trailing != null) trailing!,
      ]);
}

class SegmentedPills extends StatelessWidget {
  const SegmentedPills(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ArcadeColors.divider)),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final selected = item == value;
              return InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                      color: selected
                          ? ArcadeColors.cyan.withValues(alpha: .13)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9)),
                  child: Text(item,
                      style: TextStyle(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : ArcadeColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              );
            }).toList()),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      this.message = 'GAME OVER... nenhum registro por aqui',
      this.icon = Icons.sports_esports_outlined});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight.isFinite && constraints.maxHeight < 150;
          final horizontal = constraints.maxWidth < 340 ? 16.0 : 24.0;
          return Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontal, vertical: compact ? 12 : 24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon,
                        color: ArcadeColors.cyan.withValues(alpha: .6),
                        size: 32),
                    const SizedBox(height: 11),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: ArcadeColors.muted, fontSize: 11)),
                  ])));
        },
      );
}

class NeonDonut extends StatelessWidget {
  const NeonDonut(
      {super.key,
      required this.values,
      required this.colors,
      required this.total,
      this.labels = const ['Dinheiro', 'PIX', 'Débito', 'Crédito'],
      this.label = 'TOTAL'});
  final List<double> values;
  final List<Color> colors;
  final String total;
  final List<String> labels;
  final String label;

  String _tooltipMessage() {
    final positiveValues = values
        .where((value) => value.isFinite && value > 0)
        .toList(growable: false);
    final sum =
        positiveValues.fold<double>(0, (result, value) => result + value);
    if (sum <= 0) return 'Sem recebimentos registrados';
    return values
        .asMap()
        .entries
        .where((entry) => entry.value.isFinite && entry.value > 0)
        .map((entry) {
      final name = entry.key < labels.length
          ? labels[entry.key]
          : 'Forma ${entry.key + 1}';
      final percent = (entry.value / sum * 100).toStringAsFixed(1);
      return '$name: ${money(entry.value)} ($percent%)';
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final hasTotal = values.any((value) => value.isFinite && value > 0);
    return Tooltip(
        message: _tooltipMessage(),
        triggerMode: TooltipTriggerMode.tap,
        waitDuration: Duration.zero,
        child: SizedBox(
            width: 152,
            height: 152,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                  size: const Size(152, 152),
                  painter: _DonutPainter(values, colors)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(label,
                    style: const TextStyle(
                        color: ArcadeColors.muted,
                        fontSize: 8,
                        letterSpacing: 1)),
                const SizedBox(height: 5),
                Text(hasTotal ? total : '—',
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 18))
              ]),
            ])));
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values, this.colors);
  final List<double> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    final base = Paint()
      ..color = Colors.white.withValues(alpha: .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    final total = values
        .where((value) => value.isFinite && value > 0)
        .fold<double>(0, (sum, value) => sum + value);
    if (total <= 0 || colors.isEmpty) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      if (!values[i].isFinite || values[i] <= 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      final segmentSweep = math.max(0.0, sweep - .025);
      if (segmentSweep <= 0) {
        start += sweep;
        continue;
      }
      final color = colors[i % colors.length];
      canvas.drawArc(
          rect,
          start,
          segmentSweep,
          false,
          Paint()
            ..color = color.withValues(alpha: .22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 15
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawArc(
          rect,
          start,
          segmentSweep,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

class SmoothAreaChart extends StatefulWidget {
  const SmoothAreaChart(
      {super.key, required this.values, required this.color, this.previous});
  final List<double> values;
  final Color color;
  final List<double>? previous;

  @override
  State<SmoothAreaChart> createState() => _SmoothAreaChartState();
}

class _SmoothAreaChartState extends State<SmoothAreaChart> {
  int? _selectedIndex;
  bool _pinned = false;

  void _selectAt(double x, double width, {required bool pin}) {
    if (widget.values.isEmpty) return;
    final fraction = width <= 0 ? 0.0 : (x / width).clamp(0.0, 1.0);
    final index = (fraction * (widget.values.length - 1)).round();
    if (_selectedIndex != index || _pinned != pin) {
      setState(() {
        _selectedIndex = index;
        _pinned = pin;
      });
    }
  }

  Widget _tooltipLine(String label, double amount, Color tone) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: ArcadeColors.muted,
                        fontSize: 8,
                        letterSpacing: .35)),
                Text(money(amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'SpaceGrotesk')),
              ])),
        ]),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final index =
              _selectedIndex != null && _selectedIndex! < widget.values.length
                  ? _selectedIndex
                  : null;
          final previous = widget.previous;
          int? previousIndex;
          if (index != null && previous != null && previous.isNotEmpty) {
            final fraction = widget.values.length <= 1
                ? 0.0
                : index / (widget.values.length - 1);
            previousIndex = (fraction * (previous.length - 1)).round();
          }

          Widget chartTooltip() {
            if (index == null || width <= 0) return const SizedBox.shrink();
            final tooltipWidth = math.min(206.0, width);
            final pointX = widget.values.length <= 1
                ? width / 2
                : width * index / (widget.values.length - 1);
            final left = (pointX - tooltipWidth / 2)
                .clamp(0.0, math.max(0.0, width - tooltipWidth))
                .toDouble();
            return Positioned(
                left: left,
                top: 4,
                child: IgnorePointer(
                    child: SizedBox(
                        width: tooltipWidth,
                        child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 6),
                            borderRadius: 11,
                            glow: widget.color,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _tooltipLine('Período atual',
                                      widget.values[index], widget.color),
                                  if (previousIndex != null)
                                    _tooltipLine(
                                        'Período anterior',
                                        previous![previousIndex],
                                        ArcadeColors.purple),
                                ])))));
          }

          return SizedBox(
              width: width,
              height: 190,
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      _selectAt(details.localPosition.dx, width, pin: true),
                  child: MouseRegion(
                      onHover: (event) =>
                          _selectAt(event.localPosition.dx, width, pin: false),
                      onExit: (_) {
                        if (!_pinned && _selectedIndex != null) {
                          setState(() => _selectedIndex = null);
                        }
                      },
                      child: Stack(fit: StackFit.expand, children: [
                        CustomPaint(
                            painter: _AreaChartPainter(
                                widget.values, widget.color, widget.previous,
                                selectedIndex: index)),
                        chartTooltip(),
                      ]))));
        },
      );
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter(this.values, this.color, this.previous,
      {this.selectedIndex});
  final List<double> values;
  final Color color;
  final List<double>? previous;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final chart = Rect.fromLTWH(0, 8, size.width, size.height - 22);
    final allValues = [...values, ...?previous]
        .where((value) => value.isFinite)
        .toList(growable: false);
    final observedMaximum =
        allValues.isEmpty ? 0.0 : allValues.reduce((a, b) => math.max(a, b));
    final maximum = math.max(1.0, observedMaximum * 1.2);
    Offset pointAt(List<double> series, int index) {
      final x = series.length <= 1
          ? chart.center.dx
          : chart.width * index / (series.length - 1);
      final value = series[index].isFinite ? series[index] : 0.0;
      return Offset(x, chart.bottom - (value / maximum) * chart.height);
    }

    final points = List.generate(values.length, (i) => pointAt(values, i));
    for (var i = 1; i <= 3; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          Paint()
            ..color = Colors.white.withValues(alpha: .055)
            ..strokeWidth = 1);
    }
    if (previous != null && previous!.isNotEmpty) {
      final old = List.generate(previous!.length, (i) => pointAt(previous!, i));
      if (old.length == 1) {
        canvas.drawCircle(old.single, 2.5,
            Paint()..color = ArcadeColors.purple.withValues(alpha: .65));
      }
      if (old.length > 1) {
        final path = _smoothPath(old);
        _drawDashed(
            canvas,
            path,
            Paint()
              ..color = ArcadeColors.purple.withValues(alpha: .5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
      }
    }
    final line = _smoothPath(points);
    final fill = Path.from(line)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(colors: [
            color.withValues(alpha: .22),
            color.withValues(alpha: .005)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              .createShader(chart));
    canvas.drawPath(
        line,
        Paint()
          ..color = color.withValues(alpha: .2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    if (selectedIndex != null && selectedIndex! >= 0) {
      final selected =
          points[selectedIndex!.clamp(0, points.length - 1).toInt()];
      canvas.drawLine(
          Offset(selected.dx, chart.top),
          Offset(selected.dx, chart.bottom),
          Paint()
            ..color = color.withValues(alpha: .2)
            ..strokeWidth = 1);
      canvas.drawCircle(
          selected, 5, Paint()..color = color.withValues(alpha: .2));
      canvas.drawCircle(selected, 3, Paint()..color = color);
    }
    final last = points.last;
    canvas.drawCircle(last, 5, Paint()..color = color.withValues(alpha: .18));
    canvas.drawCircle(last, 2.5, Paint()..color = color);
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previousPoint = points[i - 1];
      final current = points[i];
      final control = (current.dx - previousPoint.dx) * .38;
      path.cubicTo(previousPoint.dx + control, previousPoint.dy,
          current.dx - control, current.dy, current.dx, current.dy);
    }
    return path;
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 5, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.previous != previous ||
      oldDelegate.selectedIndex != selectedIndex;
}

class NeonBar extends StatelessWidget {
  const NeonBar(
      {super.key,
      required this.label,
      required this.value,
      required this.max,
      required this.color,
      this.valueLabel});
  final String label;
  final double value;
  final double max;
  final Color color;
  final String? valueLabel;
  @override
  Widget build(BuildContext context) => Tooltip(
      message: '$label: ${valueLabel ?? value.toStringAsFixed(0)}',
      child: Row(children: [
        SizedBox(
            width: 94,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 10, color: ArcadeColors.muted))),
        const SizedBox(width: 10),
        Expanded(
            child: Stack(children: [
          Container(
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .055),
                  borderRadius: BorderRadius.circular(20))),
          FractionallySizedBox(
              widthFactor: max <= 0 ? 0 : (value / max).clamp(0, 1),
              child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [color.withValues(alpha: .55), color]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: color.withValues(alpha: .22), blurRadius: 8)
                      ]))),
        ])),
        const SizedBox(width: 10),
        SizedBox(
            width: 40,
            child: Text(valueLabel ?? value.toStringAsFixed(0),
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
      ]));
}

class HeaderBadge extends StatelessWidget {
  const HeaderBadge(
      {super.key,
      required this.icon,
      required this.label,
      required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w800))
      ]);
}
