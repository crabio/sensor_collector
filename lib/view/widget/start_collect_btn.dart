import 'package:flutter/material.dart';

class StartCollectButton extends StatelessWidget {
  final void Function() onPressed;
  final bool isCollectingData;

  const StartCollectButton(this.onPressed, this.isCollectingData, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCollectingData ? Colors.red : Colors.green,
      ),
      child: Text(isCollectingData ? 'Stop' : 'Start'),
    );
  }
}
