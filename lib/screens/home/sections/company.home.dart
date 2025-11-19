import 'package:flutter/material.dart';
import 'package:philgo/screens/company/company.list.screen.dart';

class CompanyHome extends StatefulWidget {
  const CompanyHome({super.key});

  @override
  State<CompanyHome> createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  @override
  Widget build(BuildContext context) {
    return CompanyListScreen();
  }
}
