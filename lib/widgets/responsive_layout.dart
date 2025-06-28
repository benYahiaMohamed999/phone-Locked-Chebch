import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width < 1400 &&
      MediaQuery.of(context).size.width >= 1100;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1400;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1400) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 1100) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 650) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: builder,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        if (constraints.maxWidth >= 1100) {
          padding = desktopPadding ?? const EdgeInsets.all(24.0);
        } else if (constraints.maxWidth >= 650) {
          padding = tabletPadding ?? const EdgeInsets.all(16.0);
        } else {
          padding = mobilePadding ?? const EdgeInsets.all(12.0);
        }
        return Padding(padding: padding, child: child);
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= 1100) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= 650) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        // Ensure we have at least 1 column and valid constraints
        columns = columns.clamp(1, children.length);
        final availableWidth = constraints.maxWidth;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (availableWidth - totalSpacing) / columns;

        // Ensure item width is positive
        final safeItemWidth =
            itemWidth > 0 ? itemWidth : availableWidth / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: safeItemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        double containerMaxWidth;
        if (constraints.maxWidth >= 1400) {
          containerMaxWidth = maxWidth ?? 1200.0;
        } else if (constraints.maxWidth >= 1100) {
          containerMaxWidth = maxWidth ?? 1000.0;
        } else if (constraints.maxWidth >= 650) {
          containerMaxWidth = maxWidth ?? 600.0;
        } else {
          containerMaxWidth = constraints.maxWidth;
        }

        // Ensure container width doesn't exceed available space
        containerMaxWidth = containerMaxWidth.clamp(0.0, constraints.maxWidth);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: containerMaxWidth,
              minWidth: 0.0,
            ),
            child: Container(
              width: containerMaxWidth,
              padding: padding,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        TextStyle responsiveStyle = style ?? const TextStyle();

        if (constraints.maxWidth >= 1400) {
          responsiveStyle = responsiveStyle.copyWith(
            fontSize: (responsiveStyle.fontSize ?? 16) * 1.2,
          );
        } else if (constraints.maxWidth >= 1100) {
          responsiveStyle = responsiveStyle.copyWith(
            fontSize: (responsiveStyle.fontSize ?? 16) * 1.1,
          );
        } else if (constraints.maxWidth < 650) {
          responsiveStyle = responsiveStyle.copyWith(
            fontSize: (responsiveStyle.fontSize ?? 16) * 0.9,
          );
        }

        return Text(
          text,
          style: responsiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class ResponsiveSpacing extends StatelessWidget {
  final double mobileSpacing;
  final double tabletSpacing;
  final double desktopSpacing;
  final bool isVertical;

  const ResponsiveSpacing({
    Key? key,
    this.mobileSpacing = 16.0,
    this.tabletSpacing = 24.0,
    this.desktopSpacing = 32.0,
    this.isVertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        double spacing;
        if (constraints.maxWidth >= 1100) {
          spacing = desktopSpacing;
        } else if (constraints.maxWidth >= 650) {
          spacing = tabletSpacing;
        } else {
          spacing = mobileSpacing;
        }

        return isVertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing);
      },
    );
  }
}

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;

  const ResponsiveIcon({
    Key? key,
    required this.icon,
    this.color,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        double size;
        if (constraints.maxWidth >= 1100) {
          size = desktopSize ?? 24.0;
        } else if (constraints.maxWidth >= 650) {
          size = tabletSize ?? 22.0;
        } else {
          size = mobileSize ?? 20.0;
        }

        return Icon(
          icon,
          size: size,
          color: color,
        );
      },
    );
  }
}
