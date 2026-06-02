import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;

  // Button appearance
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? overlayColor;
  final Color? shadowColor;
  final Color? surfaceTintColor;

  // Button dimensions
  final double? width;
  final double? height;
  final double? elevation;
  final double? disabledElevation;
  final double? hoverElevation;
  final double? focusElevation;
  final double? highlightElevation;

  // Button padding and margins
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // Button shape
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? borderSide;
  final OutlinedBorder? shape;

  // Button text
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? heightMultiplier;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final FontStyle? fontStyle;

  // Button icons
  final Widget? icon;
  final Widget? suffixIcon;
  final String? svgIconPath;
  final String? suffixSvgIconPath;
  final double? iconSize;
  final Color? iconColor;
  final double? gap;
  final MainAxisAlignment? contentAlignment;

  // Button states
  final bool isDisabled;
  final bool isFullWidth;
  final bool isOutlined;
  final bool isRounded;
  final bool hasShadow;

  // Button animation
  final Duration? animationDuration;
  final Curve? animationCurve;

  // Button interactions
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final MouseCursor? mouseCursor;
  final bool? enableFeedback;
  final bool? autofocus;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  final WidgetStateProperty<Color?>? overlayColorProperty;
  final WidgetStateProperty<Size?>? fixedSize;
  final WidgetStateProperty<Size?>? minimumSize;
  final WidgetStateProperty<Size?>? maximumSize;
  final WidgetStateProperty<double?>? elevationProperty;
  final WidgetStateProperty<Color?>? backgroundColorProperty;
  final WidgetStateProperty<Color?>? foregroundColorProperty;
  final WidgetStateProperty<Color?>? shadowColorProperty;
  final WidgetStateProperty<Color?>? surfaceTintColorProperty;
  final WidgetStateProperty<EdgeInsetsGeometry?>? paddingProperty;
  final WidgetStateProperty<OutlinedBorder?>? shapeProperty;
  final WidgetStateProperty<BorderSide?>? sideProperty;
  final WidgetStateProperty<MouseCursor?>? mouseCursorProperty;
  final WidgetStateProperty<TextStyle?>? textStyleProperty;
  final WidgetStateProperty<Color?>? iconColorProperty;
  final WidgetStateProperty<Color?>? overlayColorStateProperty;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.overlayColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.width,
    this.height,
    this.elevation,
    this.disabledElevation,
    this.hoverElevation,
    this.focusElevation,
    this.highlightElevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderSide,
    this.shape,
    this.textStyle,
    this.fontSize,
    this.textColor,
    this.fontWeight,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.heightMultiplier,
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontStyle,
    this.icon,
    this.suffixIcon,
    this.svgIconPath,
    this.suffixSvgIconPath,
    this.iconSize,
    this.iconColor,
    this.gap,
    this.contentAlignment,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.isRounded = false,
    this.hasShadow = true,
    this.animationDuration,
    this.animationCurve,
    this.materialTapTargetSize,
    this.visualDensity,
    this.mouseCursor,
    this.enableFeedback,
    this.autofocus,
    this.clipBehavior,
    this.focusNode,
    this.overlayColorProperty,
    this.fixedSize,
    this.minimumSize,
    this.maximumSize,
    this.elevationProperty,
    this.backgroundColorProperty,
    this.foregroundColorProperty,
    this.shadowColorProperty,
    this.surfaceTintColorProperty,
    this.paddingProperty,
    this.shapeProperty,
    this.sideProperty,
    this.mouseCursorProperty,
    this.textStyleProperty,
    this.iconColorProperty,
    this.overlayColorStateProperty,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Builds the merged [TextStyle] once per build, avoiding repeated allocations.
  TextStyle _resolveTextStyle(BuildContext context) {
    final base = textStyle ?? Theme.of(context).textTheme.labelLarge ?? const TextStyle();
    // Only call copyWith when at least one field differs from the base; this
    // avoids an allocation when the caller passes nothing at all.
    if (fontSize == null &&
        textColor == null &&
        foregroundColor == null &&
        fontWeight == null &&
        letterSpacing == null &&
        wordSpacing == null &&
        textBaseline == null &&
        fontFamily == null &&
        fontFamilyFallback == null &&
        fontStyle == null) {
      return base;
    }
    return base.copyWith(
      fontSize: fontSize,
      color: textColor ?? foregroundColor,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontStyle: fontStyle,
    );
  }

  /// Builds the [ButtonStyle] in a single pass (no chained copyWith).
  ButtonStyle _resolveButtonStyle(BuildContext context, TextStyle mergedTextStyle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve colors once — avoids repeated Theme traversals.
    final resolvedBg = backgroundColor ?? theme.primaryColor;
    final resolvedFg = foregroundColor ?? colorScheme.onPrimary;
    final resolvedDisabledBg = disabledBackgroundColor ?? theme.disabledColor;
    // Pre-compute the disabled-fg colour outside WidgetStateProperty to avoid
    // allocating a new Color on every state resolution.
    final resolvedDisabledFg = disabledForegroundColor ??
        colorScheme.onSurface.withValues(alpha: 0.38);
    final resolvedShadow = shadowColor ?? theme.shadowColor;

    final double resolvedHeight = height ?? 36;
    final double resolvedElevation = elevation ?? (hasShadow ? 2 : 0);

    // Shape — computed once.
    final OutlinedBorder resolvedShape = shape ??
        RoundedRectangleBorder(
          borderRadius: borderRadius ??
              (isRounded
                  ? BorderRadius.circular(resolvedHeight / 2)
                  : const BorderRadius.all(Radius.circular(8))),
          side: borderSide ??
              (isOutlined
                  ? BorderSide(color: resolvedBg, width: 1.5)
                  : BorderSide.none),
        );

    // Size — computed once.
    final Size resolvedMinSize = Size(
      isFullWidth ? double.infinity : width ?? 64,
      resolvedHeight,
    );
    final Size? resolvedFixedSize = (width != null || height != null)
        ? Size(width ?? double.infinity, resolvedHeight)
        : null;

    // Build style in a single constructor call — avoids the
    // styleFrom + copyWith double-pass that the original performed.
    return ButtonStyle(
      backgroundColor: backgroundColorProperty ??
          WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? resolvedDisabledBg : resolvedBg),
      foregroundColor: foregroundColorProperty ??
          WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? resolvedDisabledFg : resolvedFg),
      overlayColor: overlayColorStateProperty ??
          (overlayColor != null
              ? WidgetStatePropertyAll(overlayColor)
              : null),
      shadowColor: shadowColorProperty ?? WidgetStatePropertyAll(resolvedShadow),
      surfaceTintColor: surfaceTintColorProperty ??
          (surfaceTintColor != null ? WidgetStatePropertyAll(surfaceTintColor) : null),
      elevation: elevationProperty ??
          WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.disabled) ? 0 : resolvedElevation),
      textStyle: textStyleProperty ?? WidgetStatePropertyAll(mergedTextStyle),
      padding: paddingProperty ??
          WidgetStatePropertyAll(padding ?? const EdgeInsets.symmetric(horizontal: 16)),
      minimumSize: WidgetStatePropertyAll(resolvedMinSize),
      fixedSize: fixedSize ?? (resolvedFixedSize != null ? WidgetStatePropertyAll(resolvedFixedSize) : null),
      maximumSize: maximumSize ?? const WidgetStatePropertyAll(Size.infinite),
      shape: shapeProperty ?? WidgetStatePropertyAll(resolvedShape),
      side: sideProperty,
      mouseCursor: mouseCursorProperty,
      visualDensity: visualDensity ?? theme.visualDensity,
      tapTargetSize: materialTapTargetSize,
      animationDuration: animationDuration ?? const Duration(milliseconds: 200),
      enableFeedback: enableFeedback ?? true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
      iconColor: iconColorProperty,
    );
  }

  /// Returns either an SVG widget or a theme-wrapped icon widget, or null.
  Widget? _buildIconWidget(
      BuildContext context,
      String? svgPath,
      Widget? iconWidget,
      ) {
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath,
        width: iconSize,
        height: iconSize,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
            : null,
      );
    }
    if (iconWidget != null) {
      return IconTheme(
        data: IconThemeData(
          size: iconSize,
          color: iconColor ?? foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
        child: iconWidget,
      );
    }
    return null;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final TextStyle mergedTextStyle = _resolveTextStyle(context);
    final ButtonStyle buttonStyle = _resolveButtonStyle(context, mergedTextStyle);

    // Resolve icons — only do work when props are non-null.
    final Widget? prefixIcon =
    (svgIconPath != null || icon != null) ? _buildIconWidget(context, svgIconPath, icon) : null;
    final Widget? suffixIconWidget =
    (suffixSvgIconPath != null || suffixIcon != null)
        ? _buildIconWidget(context, suffixSvgIconPath, suffixIcon)
        : null;

    // Core text widget — const-eligible when no dynamic style is needed.
    Widget buttonContent = Text(
      buttonText,
      style: mergedTextStyle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );

    if (prefixIcon != null || suffixIconWidget != null) {
      final double resolvedGap = gap ?? 8;
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: contentAlignment ?? MainAxisAlignment.center,
        children: <Widget>[
          if (prefixIcon != null) ...[
            prefixIcon,
            SizedBox(width: resolvedGap),
          ],
          buttonContent,
          if (suffixIconWidget != null) ...[
            SizedBox(width: resolvedGap),
            suffixIconWidget,
          ],
        ],
      );
    }

    final Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior ?? Clip.none,
      child: buttonContent,
    );

    // Avoid wrapping in Container when margin is absent — saves a layout node.
    if (margin != null) {
      return Container(margin: margin, child: button);
    }
    return button;
  }
}


