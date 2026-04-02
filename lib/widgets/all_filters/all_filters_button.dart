import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

class AllFiltersButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const AllFiltersButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF6A5AE0) : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.format_list_bulleted,
              size: 15,
              color: Color(0xFF1C2241),
            ),
            const SizedBox(width: 5),
            Text(
              t.all_filters,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF1C2241) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
