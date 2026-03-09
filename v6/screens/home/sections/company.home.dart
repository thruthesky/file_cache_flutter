import 'package:flutter/material.dart';
import 'package:philgo/screens/company/company.list.screen.dart';

/// Company Home Section
///
/// Thin wrapper that embeds the company directory within the home tab.
/// Delegates entirely to [CompanyListScreen] which handles
/// its own header, category filters, and company list.
class CompanyHome extends StatelessWidget {
  const CompanyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompanyListScreen();
  }
}
