import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/format.dart';

/// "12:34" since [since], updated every second.
class ElapsedClock extends StatefulWidget {
  const ElapsedClock({super.key, required this.since, this.style});

  final DateTime since;
  final TextStyle? style;

  @override
  State<ElapsedClock> createState() => _ElapsedClockState();
}

class _ElapsedClockState extends State<ElapsedClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = DateTime.now().difference(widget.since).inSeconds;
    return Text(formatClock(seconds < 0 ? 0 : seconds), style: widget.style);
  }
}
