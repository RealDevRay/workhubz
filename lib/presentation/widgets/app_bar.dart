import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkHubzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const WorkHubzAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      elevation: elevation,
      actions: actions,
      leading: context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class WorkHubzSimpleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const WorkHubzSimpleAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
