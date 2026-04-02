import 'package:flutter/material.dart';

class AnimatedUrgencyBadge extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const AnimatedUrgencyBadge({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delay = const Duration(milliseconds: 80),
  });

  @override
  State<AnimatedUrgencyBadge> createState() => _AnimatedUrgencyBadgeState();
}

class _AnimatedUrgencyBadgeState extends State<AnimatedUrgencyBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    Future.delayed(widget.delay, _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
