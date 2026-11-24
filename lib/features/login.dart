import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result =
        await context.read<AppController>().signIn(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          if (wide) {
            return Row(children: [
              Expanded(flex: 6, child: _ArcadeHero(large: true)),
              Expanded(flex: 5, child: _loginPanel(maxWidth: 470)),
            ]);
          }
          return Stack(children: [
            const Positioned.fill(child: _ArcadeHero(large: false)),
            Positioned.fill(
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
              ArcadeColors.bg.withValues(alpha: .4),
              ArcadeColors.bg.withValues(alpha: .92)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
            Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 34),
                    child: _loginPanel(maxWidth: 470))),
          ]);
        }),
      );

  Widget _loginPanel({required double maxWidth}) => Center(
          child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width < 980 ? 0 : 52,
              vertical: 28),
          child: GlassCard(
            glow: ArcadeColors.cyan,
            padding: const EdgeInsets.fromLTRB(30, 32, 30, 28),
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                                color: ArcadeColors.cyan.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: ArcadeColors.cyan
                                        .withValues(alpha: .25))),
                            child: const Icon(Icons.sports_esports_rounded,
                                color: ArcadeColors.cyan, size: 22)),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FLIPERAMADA',
                                  style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize:
                                          MediaQuery.sizeOf(context).width < 390
                                              ? 10
                                              : 12,
                                      color: ArcadeColors.ink,
                                      letterSpacing: .4)),
                              const SizedBox(height: 7),
                              const Text('TI  /  ARCADE CONTROL',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: ArcadeColors.cyan,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w800)),
                            ]),
                      ]),
                      const SizedBox(height: 29),
                      Text('A próxima fase\ncomeça aqui.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  fontSize: 30,
                                  height: 1.1,
                                  letterSpacing: -1)),
                      const SizedBox(height: 9),
                      const Text('Entre no painel de controle da sua arena.',
                          style: TextStyle(
                              color: ArcadeColors.muted, fontSize: 12)),
                      const SizedBox(height: 22),
                      if (!context
                          .read<AppController>()
                          .supabaseConfigured) ...[
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color:
                                    ArcadeColors.yellow.withValues(alpha: .08),
                                border: Border.all(
                                    color: ArcadeColors.yellow
                                        .withValues(alpha: .2)),
                                borderRadius: BorderRadius.circular(13)),
                            child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.science_outlined,
                                      color: ArcadeColors.yellow, size: 17),
                                  SizedBox(width: 9),
                                  Expanded(
                                      child: Text(
                                          'MODO DEMONSTRAÇÃO · dados fictícios, sem gravação no Supabase.',
                                          style: TextStyle(
                                              color: ArcadeColors.yellow,
                                              fontSize: 10,
                                              height: 1.5,
                                              fontWeight: FontWeight.w700))),
                                ])),
                        const SizedBox(height: 18),
                      ],
                      if (context.read<AppController>().startupError !=
                          null) ...[
                        _ErrorMessage(
                            context.read<AppController>().startupError!),
                        const SizedBox(height: 14),
                      ],
                      const Text('E-MAIL',
                          style: TextStyle(
                              color: ArcadeColors.muted,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                              hintText: 'operador@fliperamada.com',
                              prefixIcon: Icon(Icons.alternate_email_rounded,
                                  size: 17)),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Informe seu e-mail.'
                                  : null),
                      const SizedBox(height: 16),
                      const Text('SENHA',
                          style: TextStyle(
                              color: ArcadeColors.muted,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: _password,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                              hintText: '••••••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  size: 17),
                              suffixIcon: IconButton(
                                  tooltip: _showPassword
                                      ? 'Ocultar senha'
                                      : 'Mostrar senha',
                                  onPressed: () => setState(
                                      () => _showPassword = !_showPassword),
                                  icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: ArcadeColors.muted))),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Informe sua senha.'
                              : null),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        _ErrorMessage(_error!)
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                          width: double.infinity,
                          child: _LoginButton(busy: _busy, onPressed: _submit)),
                      if (!context.read<AppController>().supabaseConfigured)
                        Center(
                            child: TextButton.icon(
                          onPressed: _busy
                              ? null
                              : () {
                                  _email.text = 'demo@fliperamada.ti';
                                  _password.text = 'demonstracao';
                                  _submit();
                                },
                          icon: const Icon(Icons.science_outlined, size: 15),
                          label: const Text('EXPLORAR DEMONSTRAÇÃO',
                              style: TextStyle(fontSize: 10)),
                        )),
                      const SizedBox(height: 17),
                      Center(
                          child: Text(
                              context.read<AppController>().supabaseConfigured
                                  ? 'Acesso protegido pelo Supabase Auth'
                                  : 'Preview interativa · autenticação real após configurar o Supabase',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: ArcadeColors.muted, fontSize: 9))),
                    ])),
          ),
        ),
      ));
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [ArcadeColors.cyan, ArcadeColors.purple]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: ArcadeColors.cyan.withValues(alpha: .2), blurRadius: 22)
          ]),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: busy ? null : onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (busy) ...[
                          const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)),
                          const SizedBox(width: 10)
                        ],
                        if (!busy) ...[
                          const Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8)
                        ],
                        const Flexible(
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('INSERIR FICHA E ENTRAR',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        letterSpacing: .5,
                                        fontWeight: FontWeight.w900)))),
                      ])))));
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ArcadeColors.red.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ArcadeColors.red.withValues(alpha: .22))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: ArcadeColors.red, size: 17),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: ArcadeColors.red, fontSize: 10, height: 1.45)))
      ]));
}

class _ArcadeHero extends StatelessWidget {
  const _ArcadeHero({required this.large});
  final bool large;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        const DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [ArcadeColors.bg, ArcadeColors.bg2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))),
        Image.asset('assets/images/login-arcade.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(-.55, 0),
            errorBuilder: (context, error, stack) =>
                const CustomPaint(painter: _ArcadeCabinetPainter())),
        const CustomPaint(painter: _PerspectiveGridPainter()),
        if (large)
          Positioned(
              left: 56,
              top: 48,
              child: Row(children: [
                const Icon(Icons.sports_esports_rounded,
                    color: ArcadeColors.cyan, size: 22),
                const SizedBox(width: 10),
                Text('FLIPERAMADA TI',
                    style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .86)))
              ])),
        Center(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: large ? 48 : 12, vertical: 14),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: large ? 375 : 252, width: double.infinity),
                      if (large) ...[
                        const SizedBox(height: 6),
                        Text('A ARENA NO SEU\nMODO MAIS ALTO.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                height: 1.25,
                                shadows: [
                                  Shadow(
                                      color: ArcadeColors.cyan
                                          .withValues(alpha: .45),
                                      blurRadius: 20)
                                ])),
                        const SizedBox(height: 12),
                        const Text(
                            'FICHAS, MÁQUINAS E OPERAÇÃO. TUDO NA MESMA FASE.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ArcadeColors.muted,
                                fontSize: 9,
                                letterSpacing: 1.25)),
                      ],
                    ]))),
        Positioned(
            left: 0,
            right: 0,
            bottom: -3,
            height: large ? 200 : 130,
            child: IgnorePointer(
                child: CustomPaint(painter: _FloorGridPainter()))),
      ]);
}

class _PerspectiveGridPainter extends CustomPainter {
  const _PerspectiveGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArcadeColors.cyan.withValues(alpha: .045)
      ..strokeWidth = 1;
    for (var i = 0; i < 13; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(size.width * .5, size.height * .35),
          Offset(x, size.height), paint);
    }
    for (var i = 0; i < 12; i++) {
      final t = i / 11;
      final y = size.height * (.40 + t * t * .60);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dots = [
      Offset(size.width * .19, size.height * .21),
      Offset(size.width * .82, size.height * .18),
      Offset(size.width * .72, size.height * .52),
      Offset(size.width * .14, size.height * .68)
    ];
    for (var i = 0; i < dots.length; i++) {
      canvas.drawCircle(
          dots[i],
          i.isEven ? 1.5 : 1,
          Paint()
            ..color = (i.isEven ? ArcadeColors.magenta : ArcadeColors.cyan)
                .withValues(alpha: .65));
    }
  }

  @override
  bool shouldRepaint(covariant _PerspectiveGridPainter oldDelegate) => false;
}

class _ArcadeCabinetPainter extends CustomPainter {
  const _ArcadeCabinetPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width * .35;
    final cx = size.width * .5;
    final left = cx - unit * .5;
    final top = size.height * .06;
    final cabinet = Rect.fromLTWH(left, top + 16, unit, size.height * .72);
    final shape = RRect.fromRectAndRadius(cabinet, const Radius.circular(17));
    final cyan = Paint()
      ..color = ArcadeColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final magenta = Paint()
      ..color = ArcadeColors.magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
        shape,
        Paint()
          ..color = ArcadeColors.cyan.withValues(alpha: .15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 23));
    canvas.drawRRect(shape, cyan);
    final bezel = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + unit * .12, top + size.height * .18, unit * .76,
            size.height * .35),
        const Radius.circular(9));
    canvas.drawRRect(bezel, Paint()..color = const Color(0xFF10172D));
    canvas.drawRRect(
        bezel,
        Paint()
          ..color = ArcadeColors.magenta.withValues(alpha: .62)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final glow = Paint()
      ..shader = const LinearGradient(colors: [
        ArcadeColors.cyan,
        ArcadeColors.purple,
        ArcadeColors.magenta
      ]).createShader(bezel.outerRect);
    final screen = RRect.fromRectAndRadius(
        bezel.outerRect.deflate(7), const Radius.circular(4));
    canvas.drawRRect(screen, Paint()..color = const Color(0xFF0A0B1E));
    canvas.drawLine(Offset(screen.left + 10, screen.bottom - 12),
        Offset(screen.right - 12, screen.top + 15), glow..strokeWidth = 2.3);
    canvas.drawCircle(
        Offset(left + unit * .39, top + size.height * .60),
        8,
        Paint()
          ..color = ArcadeColors.magenta.withValues(alpha: .75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(Offset(left + unit * .39, top + size.height * .60), 4.6,
        magenta..style = PaintingStyle.fill);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
          Offset(left + unit * (.59 + i * .1),
              top + size.height * (.58 + (i.isOdd ? .035 : 0))),
          3.5,
          Paint()..color = i == 1 ? ArcadeColors.cyan : ArcadeColors.magenta);
    }
    final base = Path()
      ..moveTo(left + unit * .08, cabinet.bottom - 2)
      ..lineTo(left + unit * .16, size.height * .94)
      ..lineTo(left + unit * .84, size.height * .94)
      ..lineTo(left + unit * .92, cabinet.bottom - 2)
      ..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFF12152B));
    canvas.drawPath(base, cyan..strokeWidth = 2);
    final star = Paint()..color = ArcadeColors.cyan.withValues(alpha: .85);
    for (final point in [
      Offset(size.width * .22, size.height * .17),
      Offset(size.width * .73, size.height * .13),
      Offset(size.width * .80, size.height * .36),
      Offset(size.width * .16, size.height * .47)
    ]) {
      canvas.drawCircle(point, 1.3, star);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeCabinetPainter oldDelegate) => false;
}

class _FloorGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArcadeColors.purple.withValues(alpha: .13)
      ..strokeWidth = 1;
    final horizon = size.height * .08;
    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(Offset(size.width / 2 + i * 8, horizon),
          Offset(size.width / 2 + i * size.width / 5, size.height), paint);
    }
    for (var i = 0; i < 9; i++) {
      final t = i / 8;
      final y = horizon + t * t * (size.height - horizon);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloorGridPainter oldDelegate) => false;
}
