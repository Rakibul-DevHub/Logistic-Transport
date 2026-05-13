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

    // Button appearance
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.overlayColor,
    this.shadowColor,
    this.surfaceTintColor,

    // Button dimensions
    this.width,
    this.height,
    this.elevation,
    this.disabledElevation,
    this.hoverElevation,
    this.focusElevation,
    this.highlightElevation,

    // Button padding and margins
    this.padding,
    this.margin,

    // Button shape
    this.borderRadius,
    this.borderSide,
    this.shape,

    // Button text
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

    // Button icons
    this.icon,
    this.suffixIcon,
    this.svgIconPath,
    this.suffixSvgIconPath,
    this.iconSize,
    this.iconColor,
    this.gap,
    this.contentAlignment,

    // Button states
    this.isDisabled = false,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.isRounded = false,
    this.hasShadow = true,

    // Button animation
    this.animationDuration,
    this.animationCurve,

    // Button interactions
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

  @override
  Widget build(BuildContext context) {
    // Merge provided text style with defaults
    final TextStyle mergedTextStyle = (textStyle ?? Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(
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

    // Determine button shape with proper priority
    final OutlinedBorder buttonShape = shape ?? RoundedRectangleBorder(
      borderRadius: borderRadius ?? (isRounded
          ? BorderRadius.circular(height != null ? height! / 2 : 24)
          : BorderRadius.circular(8)),
      side: borderSide ?? (isOutlined
          ? BorderSide(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        width: 1.5,
      )
          : BorderSide.none),
    );

    // Button style
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      disabledBackgroundColor: disabledBackgroundColor ?? Theme.of(context).disabledColor,
      disabledForegroundColor: disabledForegroundColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      shadowColor: shadowColor ?? Theme.of(context).shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation ?? (hasShadow ? 2 : 0),
      minimumSize: Size(
        isFullWidth ? double.infinity : width ?? 64,
        height ?? 36,
      ),
      fixedSize: width != null || height != null
          ? Size(width ?? double.infinity, height ?? 36)
          : null,
      maximumSize: maximumSize?.resolve({}) ?? Size.infinite,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      enableFeedback: enableFeedback ?? true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
      visualDensity: visualDensity ?? Theme.of(context).visualDensity,
      tapTargetSize: materialTapTargetSize,
      animationDuration: animationDuration ?? const Duration(milliseconds: 200),
    ).copyWith(
      shape: WidgetStateProperty.all(buttonShape), // Apply the shape here
      overlayColor: overlayColorStateProperty ?? (overlayColor != null
          ? WidgetStateProperty.all(overlayColor)
          : null),
      elevation: elevationProperty,
      backgroundColor: backgroundColorProperty,
      foregroundColor: foregroundColorProperty,
      shadowColor: shadowColorProperty,
      surfaceTintColor: surfaceTintColorProperty,
      padding: paddingProperty,
      side: sideProperty,
      mouseCursor: mouseCursorProperty,
      textStyle: textStyleProperty ?? WidgetStateProperty.all(mergedTextStyle),
      iconColor: iconColorProperty,
    );

    // Button content
    Widget buttonContent = Text(
      buttonText,
      style: mergedTextStyle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );

    // Build icon widget (either regular icon or SVG icon)
    Widget? buildIconWidget(String? svgPath, Widget? iconWidget) {
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
      return iconWidget != null
          ? IconTheme(
        data: IconThemeData(
          size: iconSize,
          color: iconColor ?? foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
        child: iconWidget,
      )
          : null;
    }

    // Add icon(s) if provided
    final Widget? prefixIcon = buildIconWidget(svgIconPath, icon);
    final Widget? suffixIconWidget = buildIconWidget(suffixSvgIconPath, suffixIcon);

    if (prefixIcon != null || suffixIconWidget != null) {
      final List<Widget> children = [];

      if (prefixIcon != null) {
        children.add(prefixIcon);
        if (suffixIconWidget == null) {
          children.add(SizedBox(width: gap ?? 8));
        }
      }

      children.add(buttonContent);

      if (suffixIconWidget != null) {
        if (prefixIcon != null) {
          children.add(SizedBox(width: gap ?? 8));
        }
        children.add(suffixIconWidget);
      }

      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: contentAlignment ?? MainAxisAlignment.center,
        children: children,
      );
    }

    return Container(
      margin: margin,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        focusNode: focusNode,
        autofocus: autofocus ?? false,
        clipBehavior: clipBehavior ?? Clip.none,
        child: buttonContent,
      ),
    );
  }
}