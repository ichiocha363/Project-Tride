import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import '../Constants/app_colors.dart';

class CustomFloatingNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final PageController? pageController;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.pageController,
  });

  @override
  State<CustomFloatingNavBar> createState() => _CustomFloatingNavBarState();
}

class _CustomFloatingNavBarState extends State<CustomFloatingNavBar> {
  late final NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant CustomFloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.index = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = AppColors.primaryDeep;
    const Color inactiveColor = AppColors.textSecondary;

    return AnimatedNotchBottomBar(
      notchBottomBarController: _controller,
      color: Colors.white,
      showBlurBottomBar: false,
      showLabel: true,
      notchColor: activeColor,
      removeMargins: false,
      bottomBarWidth: 500,
      showShadow: true,
      elevation: 3.0,
      shadowElevation: 8.0,
      itemLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: inactiveColor,
        fontFamily: 'Plus Jakarta Sans',
      ),
      bottomBarItems: const [
        BottomBarItem(
          inActiveItem: Icon(
            Icons.home_outlined,
            color: inactiveColor,
          ),
          activeItem: _AnimatedNavIcon(icon: Icons.home_rounded),
          itemLabel: 'Beranda',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.explore_outlined,
            color: inactiveColor,
          ),
          activeItem: _AnimatedNavIcon(icon: Icons.explore_rounded),
          itemLabel: 'Jelajah',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.luggage_outlined,
            color: inactiveColor,
          ),
          activeItem: _AnimatedNavIcon(icon: Icons.luggage_rounded),
          itemLabel: 'AI Planner',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.account_balance_wallet_outlined,
            color: inactiveColor,
          ),
          activeItem: _AnimatedNavIcon(icon: Icons.account_balance_wallet_rounded),
          itemLabel: 'Anggaran',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.person_outline_rounded,
            color: inactiveColor,
          ),
          activeItem: _AnimatedNavIcon(icon: Icons.person_rounded),
          itemLabel: 'Profil',
        ),
      ],
      onTap: (index) {
        widget.onDestinationSelected(index);
      },
      kIconSize: 22.0,
      kBottomRadius: 24.0,
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;

  const _AnimatedNavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(icon),
      tween: Tween<double>(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
