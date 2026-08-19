import 'package:flutter/material.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF004AC6);
    const Color inactiveColor = Color(0xFF64748B);

    final List<_NavBarItemData> items = [
      const _NavBarItemData(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      const _NavBarItemData(
        label: 'Explore',
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
      ),
      const _NavBarItemData(
        label: 'Trips',
        icon: Icons.luggage_outlined,
        activeIcon: Icons.luggage_rounded,
      ),
      const _NavBarItemData(
        label: 'Budget',
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
      ),
      const _NavBarItemData(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;
            final item = items[index];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onDestinationSelected(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Active indicator dot
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? activeColor : Colors.transparent,
                      ),
                    ),
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? activeColor : inactiveColor,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? activeColor : inactiveColor,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavBarItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
