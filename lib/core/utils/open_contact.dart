import 'package:url_launcher/url_launcher.dart';

Future<void> openEmailApp(String email) async {
  final address = email.trim();
  if (address.isEmpty) return;
  final gmail = Uri.parse('googlegmail://co?to=${Uri.encodeComponent(address)}');
  final openedGmail = await launchUrl(gmail, mode: LaunchMode.externalApplication);
  if (openedGmail) return;
  await launchUrl(
    Uri(scheme: 'mailto', path: address),
    mode: LaunchMode.externalApplication,
  );
}

Future<void> openPhoneDialer(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) return;
  await launchUrl(
    Uri(scheme: 'tel', path: digits),
    mode: LaunchMode.externalApplication,
  );
}
