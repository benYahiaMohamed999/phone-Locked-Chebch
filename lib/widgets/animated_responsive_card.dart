import 'package:flutter/material.dart';

class AnimatedResponsiveCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const AnimatedResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedResponsiveCard> createState() => _AnimatedResponsiveCardState();
}

class _AnimatedResponsiveCardState extends State<AnimatedResponsiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure we have valid constraints
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        final screenWidth = constraints.maxWidth;

        // Determine responsive padding
        EdgeInsets responsivePadding;
        if (screenWidth < 600) {
          responsivePadding = widget.padding ?? const EdgeInsets.all(12);
        } else if (screenWidth < 900) {
          responsivePadding = widget.padding ?? const EdgeInsets.all(16);
        } else if (screenWidth < 1200) {
          responsivePadding = widget.padding ?? const EdgeInsets.all(20);
        } else {
          responsivePadding = widget.padding ?? const EdgeInsets.all(24);
        }

        Widget card = Card(
          elevation: widget.elevation ?? 0,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          ),
          color: widget.backgroundColor ?? theme.colorScheme.surface,
          child: Padding(
            padding: responsivePadding,
            child: widget.child,
          ),
        );

        if (widget.onTap != null) {
          return GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: card,
                );
              },
            ),
          );
        }

        return card;
      },
    );
  }
}
