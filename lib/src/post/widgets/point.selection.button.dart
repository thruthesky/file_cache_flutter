import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// ! WARNING: the setting may not be loaded by the time it is built -> We don't care for it.
///
///
class PointSelectionButton extends StatelessWidget {
  const PointSelectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                if (PhilgoService.instance.setting?.point != null)
                  ...PhilgoService.instance.setting!.point.advertisementDays
                      .map((days) => Text('$days Days')),
              ],
            );
          },
        );
      },
      child: Text('Point Adv'),
    );
  }
}
