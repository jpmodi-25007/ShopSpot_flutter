import 'package:flutter/material.dart';

class AppColors {
  // Primary - Customer Role (Premium Chocolate)
  static const Color primary600 = Color(0xFF4E342E); // Deep Chocolate
  static const Color primary500 = Color(0xFF5D4037);
  static const Color primary400 = Color(0xFF795548);
  static const Color primary300 = Color(0xFFA1887F);
  static const Color primary200 = Color(0xFFBCAAA4);
  static const Color primary100 = Color(0xFFEFEBE9);
  static const Color primary50 = Color(0xFFF7F5F4);

  static const Color secondary500 = Color(0xFFF59E0B);
  static const Color secondary400 = Color(0xFFFBBF24);
  static const Color secondary100 = Color(0xFFFEF3C7);

  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50 = Color(0xFFF9FAFB);

  static const Color white = Color(0xFFFFFFFF);

  static const Color success600 = Color(0xFF059669);
  static const Color success500 = Color(0xFF10B981);
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color success50 = Color(0xFFECFDF5);

  static const Color error500 = Color(0xFFEF4444);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color error50 = Color(0xFFFEF2F2);

  static const Color warning600 = Color(0xFFEA580C);
  static const Color warning500 = Color(0xFFF97316);
  static const Color warning100 = Color(0xFFFFEDD5);
  static const Color warning50 = Color(0xFFFFF7ED);

  static const Color info500 = Color(0xFF3B82F6);
  static const Color info100 = Color(0xFFEFF6FF);
  static const Color info50 = Color(0xFFF0F9FF);

  // ── Centralized Role Colors ───────────────────────────────────────────────
  static const Color roleCustomer = primary600;
  static const Color roleCustomerLight = primary100;
  
  static const Color roleRetailer = success600;
  static const Color roleRetailerLight = success100;
  
  static const Color roleInfluencer = secondary500;
  static const Color roleInfluencerLight = secondary100;

  // ── Centralized Desktop Panel / Splash Theme ──────────────────────────────
  static const Color panelBackground = Color(0xFF2C1A0E); // Deep chocolate fallback
  static const Color panelGradientBottom = Color(0xE0160F08); // Very dark chocolate
  static const Color panelGradientMid = Color(0x66193318); // Forest green mid
  static const Color panelBadgeBackground = Color(0xD92D6A4F); // Green accent badge
}
