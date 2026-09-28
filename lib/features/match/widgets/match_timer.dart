import 'dart:async';

import 'package:flutter/material.dart';
import 'package:runout/domain/models/match.dart';

class MatchTimer extends StatefulWidget {
  const new({required this.match, super.key});

  final Match match;

  @override
  State<MatchTimer> createState() => _MatchTimerState();
}

class _MatchTimerState extends State<MatchTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant MatchTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.status != widget.match.status) {
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (widget.match.status == MatchStatus.playing) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {});
      });
    }
  }

  Duration get _elapsed {
    final start = widget.match.startedAt;
    if (start == null) return Duration.zero;
    final end = widget.match.endedAt ?? DateTime.now();
    return end.difference(start);
  }

  String get _formatted {
    final e = _elapsed;
    final hours = e.inHours;
    final minutes = e.inMinutes.remainder(60);
    final seconds = e.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Text(
          _formatted,
          style: const TextStyle(
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
