import 'package:flutter/material.dart';

/// 연락처 아이템 데이터 클래스 (Contact Item Data Class)
///
/// 각 연락처의 아이콘, 이름, 전화번호, 설명을 담습니다.
/// Contains icon, name, phone number, and description for each contact.
class ContactItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 이름 (Name)
  final String name;

  /// 전화번호 목록 (Phone numbers)
  final List<String> phones;

  /// 부가 설명 (Description - optional)
  final String? description;

  /// 주소 (Address - optional)
  final String? address;

  /// 이메일 (Email - optional)
  final String? email;

  /// 홈페이지 (Website - optional)
  final String? website;

  /// 긴급 여부 (Is emergency)
  final bool isEmergency;

  const ContactItem({
    required this.icon,
    required this.name,
    required this.phones,
    this.description,
    this.address,
    this.email,
    this.website,
    this.isEmergency = false,
  });
}
