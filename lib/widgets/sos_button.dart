import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  const SosButton({
    super.key,
    required this.isActive,
    required this.isBusy,
    required this.onPressed,
  });

  final bool isActive;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.red[900] : Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: isActive ? 30 : 15,
              spreadRadius: isActive ? 10 : 4,
            ),
          ],
        ),
        child: Center(
          child:
              isBusy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.warning_amber_rounded : Icons.sos,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isActive ? 'SOS ACTIVE' : 'SOS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
